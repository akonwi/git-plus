fs = require 'fs-plus'
Path = require 'path'

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
templateFilePath = '~/template'
commitTemplate = 'foobar'
commitFileContent =
  toString: -> commitFileContent
  indexOf: -> 5
  substring: -> 'commit message'
  split: (splitPoint) -> if splitPoint is '\n' then ['commit message', '# comments to be deleted']
commitResolution = Promise.resolve 'commit success'

setupMocks = ({commentChar, template}={}) ->
  commentChar ?= null
  template ?= ''
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
  spyOn(commitFileContent, 'substring').andCallThrough()
  spyOn(fs, 'readFileSync').andCallFake ->
    if fs.readFileSync.mostRecentCall.args[0] is fs.absolute(templateFilePath)
      template
    else
      commitFileContent
  spyOn(fs, 'writeFileSync')
  spyOn(fs, 'writeFile')
  spyOn(fs, 'unlink')
  spyOn(git, 'refresh')
  spyOn(git, 'getConfig').andCallFake ->
    arg = git.getConfig.mostRecentCall.args[1]
    if arg is 'commit.template'
      templateFilePath
    else if arg is 'core.commentchar'
      commentChar
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
      expect(git.getConfig).toHaveBeenCalledWith repo, 'core.commentchar'

    it "gets staged files", ->
      expect(git.cmd).toHaveBeenCalledWith ['status'], cwd: repo.getWorkingDirectory()

    it "removes lines with '(...)' from status", ->
      expect(status.replace).toHaveBeenCalled()

    it "gets the commit template from git configs", ->
      expect(git.getConfig).toHaveBeenCalledWith repo, 'commit.template'

    it "writes to a file", ->
      argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
      expect(argsTo_fsWriteFile[0]).toEqual commitFilePath

    it "shows the file", ->
      expect(atom.workspace.open).toHaveBeenCalled()

    it "calls git.cmd with ['commit'...] on textEditor save", ->
      textEditor.save()
      waitsFor -> git.cmd.callCount > 1
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['commit', "--cleanup=strip", "--file=#{commitFilePath}"], cwd: repo.getWorkingDirectory()

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
        args = fs.writeFileSync.mostRecentCall.args
        expect(args[1].trim().charAt(0)).toBe '#'

  describe "when core.commentchar config is set to '$'", ->
    it "uses '$' as the commentchar", ->
      setupMocks(commentChar: '$')
      waitsForPromise -> GitCommit(repo)
      runs ->
        args = fs.writeFileSync.mostRecentCall.args
        expect(args[1].trim().charAt(0)).toBe '$'

  describe "when commit.template config is not set", ->
    it "commit file starts with a blank line", ->
      setupMocks()
      waitsForPromise ->
        GitCommit(repo).then ->
          argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
          expect(argsTo_fsWriteFile[1].charAt(0)).toEqual "\n"

  describe "when commit.template config is set", ->
    it "commit file starts with content of that file", ->
      template = 'template'
      setupMocks({template})
      GitCommit(repo)
      waitsFor ->
        fs.writeFileSync.callCount > 0
      runs ->
        args = fs.writeFileSync.mostRecentCall.args
        expect(args[1].indexOf(template)).toBe 0

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

    it "notifies of error and closes commit pane", ->
      textEditor.save()
      waitsFor -> notifier.addError.callCount > 0
      runs ->
        expect(notifier.addError).toHaveBeenCalledWith 'commit error'
        expect(commitPane.destroy).toHaveBeenCalled()

  describe "when the verbose commit setting is true", ->
    beforeEach ->
      atom.config.set "git-plus.openInPane", false
      atom.config.set "git-plus.experimental", true
      atom.config.set "git-plus.verboseCommits", true
      setupMocks()

    it "calls git.cmd with the --verbose flag", ->
      waitsForPromise -> GitCommit(repo)
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['diff', '--color=never', '--staged'], cwd: repo.getWorkingDirectory()

    it "trims the commit file", ->
      textEditor.save()
      waitsFor -> commitFileContent.substring.callCount > 0
      runs ->
        expect(commitFileContent.substring).toHaveBeenCalledWith 0, commitFileContent.indexOf()

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
