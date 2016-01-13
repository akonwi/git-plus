fs = require 'fs-plus'
Path = require 'flavored-path'

{
  repo,
  workspace,
  pathToRepoFile,
  currentPane,
  textEditor,
  commitPane
} = require '../fixtures'
git = require '../../lib/git'
GitCommit = require '../../lib/models/git-commit'
notifier = require '../../lib/notifier'

commitFilePath = Path.join(repo.getPath(), 'COMMIT_EDITMSG')
status =
  replace: -> status
  trim: -> status
commentchar_config = ''
templateFile = ''
commitTemplate = 'foobar'
commitResolution = Promise.resolve 'commit success'

setupMocks = ->
  atom.config.set 'git-plus.openInPane', false
  spyOn(currentPane, 'activate')
  spyOn(commitPane, 'destroy').andCallThrough()
  spyOn(commitPane, 'splitRight')
  spyOn(atom.workspace, 'getActivePane').andReturn currentPane
  spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
  spyOn(atom.workspace, 'getPanes').andReturn [currentPane, commitPane]
  spyOn(atom.workspace, 'paneForURI').andReturn commitPane
  spyOn(status, 'replace').andCallFake -> status
  spyOn(status, 'trim').andCallThrough()
  spyOn(fs, 'readFileSync').andCallFake ->
    if fs.readFileSync.mostRecentCall.args[0] is 'template'
      commitTemplate
    else
      ''
  spyOn(fs, 'writeFileSync')
  spyOn(fs, 'writeFile')
  spyOn(fs, 'unlink')
  spyOn(git, 'refresh')
  spyOn(git, 'getConfig').andCallFake ->
    arg = git.getConfig.mostRecentCall.args[0]
    if arg is 'commit.template'
      Promise.resolve templateFile
    else if arg is 'core.commentchar'
      Promise.resolve commentchar_config
  spyOn(git, 'cmd').andCallFake ->
    args = git.cmd.mostRecentCall.args[0]
    if args[0] is 'status'
      Promise.resolve status
    else if args[0] is 'commit'
      commitResolution
    else if args[0] is 'diff'
      Promise.resolve 'diff'
  spyOn(git, 'stagedFiles').andCallFake ->
    args = git.stagedFiles.mostRecentCall.args
    if args[0].getWorkingDirectory() is repo.getWorkingDirectory()
      Promise.resolve [pathToRepoFile]
  spyOn(git, 'add').andCallFake ->
    args = git.add.mostRecentCall.args
    if args[0].getWorkingDirectory() is repo.getWorkingDirectory() and args[1].update
      Promise.resolve true

  spyOn(notifier, 'addError')
  spyOn(notifier, 'addInfo')
  spyOn(notifier, 'addSuccess')

describe "GitCommit", ->
  describe "a regular commit", ->
    beforeEach ->
      atom.config.set "git-plus.openInPane", false
      commitResolution = Promise.resolve 'commit success'
      setupMocks()
      waitsForPromise ->
        GitCommit(repo)

    it "gets the current pane", ->
      expect(atom.workspace.getActivePane).toHaveBeenCalled()

    it "gets the commentchar from configs", ->
      expect(git.getConfig).toHaveBeenCalledWith 'core.commentchar', Path.dirname(commitFilePath)

    it "gets staged files", ->
      expect(git.cmd).toHaveBeenCalledWith ['status'], cwd: repo.getWorkingDirectory()

    it "removes lines with '(...)' from status", ->
      expect(status.replace).toHaveBeenCalled()

    it "gets the commit template from git configs", ->
      expect(git.getConfig).toHaveBeenCalledWith 'commit.template', Path.dirname(commitFilePath)

    it "writes to a file", ->
      argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
      expect(argsTo_fsWriteFile[0]).toEqual commitFilePath

    it "shows the file", ->
      expect(atom.workspace.open).toHaveBeenCalled()

    it "calls git.cmd with ['commit'...] on textEditor save", ->
      textEditor.save()
      expect(git.cmd).toHaveBeenCalledWith ['commit', '--cleanup=strip', "--file=#{commitFilePath}"], cwd: repo.getWorkingDirectory()

    it "closes the commit pane when commit is successful", ->
      textEditor.save()
      waitsFor -> commitPane.destroy.callCount > 0
      runs -> expect(commitPane.destroy).toHaveBeenCalled()

    it "notifies of success when commit is successful", ->
      textEditor.save()
      waitsFor -> notifier.addSuccess.callCount > 0
      runs -> expect(notifier.addSuccess).toHaveBeenCalledWith 'commit success'

    it "cancels the commit on textEditor destroy", ->
      textEditor.destroy()
      expect(currentPane.activate).toHaveBeenCalled()
      expect(fs.unlink).toHaveBeenCalledWith commitFilePath

  describe "when core.commentchar config is not set", ->
    it "uses '#' in commit file", ->
      setupMocks()
      GitCommit(repo).then ->
        argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
        expect(argsTo_fsWriteFile[1].trim().charAt(0)).toBe '#'

  describe "when core.commentchar config is set to '$'", ->
    it "uses '$' as the commentchar", ->
      commentchar_config = '$'
      setupMocks()
      GitCommit(repo).then ->
        argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
        expect(argsTo_fsWriteFile[1].trim().charAt(0)).toBe commentchar_config

  describe "when commit.template config is not set", ->
    it "commit file starts with a blank line", ->
      setupMocks()
      waitsForPromise ->
        GitCommit(repo).then ->
          argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
          expect(argsTo_fsWriteFile[1].charAt(0)).toEqual "\n"

  describe "when commit.template config is set", ->
    it "commit file starts with content of that file", ->
      templateFile = 'template'
      setupMocks()
      GitCommit(repo)
      waitsFor ->
        fs.writeFileSync.callCount > 0
      runs ->
        argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
        expect(argsTo_fsWriteFile[1].indexOf(commitTemplate)).toBe 0

  describe "when 'stageChanges' option is true", ->
    it "calls git.add with update option set to true", ->
      setupMocks()
      GitCommit(repo, stageChanges: true).then ->
        expect(git.add).toHaveBeenCalledWith repo, update: true

  describe "a failing commit", ->
    beforeEach ->
      atom.config.set "git-plus.openInPane", false
      commitResolution = Promise.reject 'commit error'
      setupMocks()
      waitsForPromise ->
        GitCommit(repo)

    it "notifies of error and doesn't close commit pane", ->
      textEditor.save()
      waitsFor -> notifier.addError.callCount > 0
      runs ->
        expect(notifier.addError).toHaveBeenCalledWith 'commit error'
        expect(commitPane.destroy).not.toHaveBeenCalled()

  ## atom.config.get('git-plus.openInPane') is always false inside the module
  # describe "when the `git-plus.openInPane` setting is true", ->
  #   it "defaults to opening to the right", ->
  #     setupMocks()
  #     atom.config.set 'git-plus.openInPane', false
  #     waitsForPromise -> GitCommit(repo).then ->
  #       expect(commitPane.splitRight).toHaveBeenCalled()
#
#   ## Tough as nails to test because GitPush is called outside of test
#   # describe "when 'andPush' option is true", ->
#   #   it "calls git.cmd with ['remote'...] as args", ->
#   #     setupMocks()
#   #     GitCommit(repo, andPush: true).then ->
#   #       runs ->
#   #         textEditor.save()
#   #       waitsFor((->
#   #         git.cmd.mostRecentCall.args[0][0] is 'remote'),
#   #         "some stuff", 10000
#   #       )
#   #       expect(git.cmd).toHaveBeenCalledWith ['remote']
