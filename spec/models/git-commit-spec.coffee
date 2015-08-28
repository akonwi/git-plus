fs = require 'fs-plus'
Path = require 'flavored-path'

{repo, workspace, pathToRepoFile} = require '../fixtures'
git = require '../../lib/git'
GitCommit = require '../../lib/models/git-commit-beta'

commitFilePath = Path.join(repo.getPath(), 'COMMIT_EDITMSG')
status =
  replace: -> status
  trim: -> status
textEditor =
  onDidSave: (@save) -> dispose: ->
  onDidDestroy: (@destroy) -> dispose: ->
currentPane =
  alive: true
  activate: -> undefined
  getItems: -> [
    getURI: -> pathToRepoFile
  ]
commitPane =
  alive: true
  destroy: -> textEditor.destroy()
  getItems: -> [
    getURI: -> commitFilePath
  ]
commentchar_config = ''
templateFile = ''
commitTemplate = 'foobar'

setupMocks = ->
  spyOn(currentPane, 'activate')
  spyOn(commitPane, 'destroy')

  spyOn(atom.workspace, 'getActivePane').andReturn currentPane
  spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
  spyOn(atom.workspace, 'getPanes').andReturn [currentPane, commitPane]

  spyOn(status, 'replace').andCallFake -> status
  spyOn(status, 'trim').andCallThrough()

  spyOn(fs, 'readFileSync').andCallFake ->
    if fs.readFileSync.mostRecentCall.args[0] is 'template'
      commitTemplate
    else
      ''
  spyOn(fs, 'writeFileSync')
  spyOn(fs, 'unlinkSync')

  spyOn(git, 'refresh')
  spyOn(git, 'cmd').andCallFake ->
    args = git.cmd.mostRecentCall.args[0]
    if args[0] is 'config' and args[2] is 'commit.template'
      Promise.resolve templateFile
    else if args[0] is 'config' and args[2] is 'core.commentchar'
      Promise.resolve commentchar_config
    else if args[0] is 'status'
      Promise.resolve status
    else if args[0] is 'commit'
      Promise.resolve 'commit success'

  spyOn(git, 'stagedFiles').andCallFake ->
    args = git.stagedFiles.mostRecentCall.args
    if args[0].getWorkingDirectory() is repo.getWorkingDirectory()
      Promise.resolve [pathToRepoFile]

  spyOn(git, 'add').andCallFake ->
    args = git.add.mostRecentCall.args
    if args[0].getWorkingDirectory() is repo.getWorkingDirectory() and args[1].update
      Promise.resolve true

describe "GitCommit", ->
  describe "a regular commit", ->
    it "gets the current pane", ->
      setupMocks()
      GitCommit repo
      expect(atom.workspace.getActivePane).toHaveBeenCalled()

    describe "::start", ->
      beforeEach ->
        atom.config.set "git-plus.openInPane", false
        setupMocks()
        waitsForPromise ->
          GitCommit(repo).start()

      it "gets the commentchar from configs", ->
        expect(git.cmd).toHaveBeenCalledWith ['config', '--get', 'core.commentchar']

      it "gets staged files", ->
        expect(git.cmd).toHaveBeenCalledWith ['status'], cwd: repo.getWorkingDirectory()

      it "removes lines with '(...)' from status", ->
        expect(status.replace).toHaveBeenCalled()

      it "gets the commit template from git configs", ->
        expect(git.cmd).toHaveBeenCalledWith ['config', '--get', 'commit.template']

      it "writes to a file", ->
        argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
        expect(argsTo_fsWriteFile[0]).toEqual commitFilePath

      it "shows the file", ->
        expect(atom.workspace.open).toHaveBeenCalled()

      it "calls git.cmd with ['commit'...] on textEditor save", ->
        textEditor.save()
        expect(git.cmd).toHaveBeenCalledWith ['commit', '--cleanup=strip', "--file=#{commitFilePath}"], cwd: repo.getWorkingDirectory()

      ## Tough to test and keep mocks here because the commitPane is destroyed
      ## in a separate promise from commit::start
      # it "closes the commit pane when commit is successful", ->
      #   textEditor.save()
      #   expect(commitPane.destroy).toHaveBeenCalled()

      it "cancels the commit on textEditor destroy", ->
        textEditor.destroy()
        expect(currentPane.activate).toHaveBeenCalled()
        expect(fs.unlinkSync).toHaveBeenCalledWith commitFilePath

    describe "when core.commentchar config is not set", ->
      it "uses '#' in commit file", ->
        setupMocks()
        GitCommit(repo).start().then ->
          argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
          expect(argsTo_fsWriteFile[1].trim().charAt(0)).toBe '#'

    describe "when core.commentchar config is set to '$'", ->
      it "uses '$' as the commentchar", ->
        commentchar_config = '$'
        setupMocks()
        GitCommit(repo).start().then ->
          argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
          expect(argsTo_fsWriteFile[1].trim().charAt(0)).toBe commentchar_config

    describe "when commit.template config is not set", ->
      it "commit file starts with a blank line", ->
        setupMocks()
        waitsForPromise ->
          GitCommit(repo).start().then ->
            argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
            expect(argsTo_fsWriteFile[1].charAt(0)).toEqual "\n"

    describe "when commit.template config is set", ->
      it "commit file starts with content of that file", ->
        templateFile = 'template'
        setupMocks()
        GitCommit(repo).start()
        waitsFor ->
          fs.writeFileSync.callCount > 0
        runs ->
          argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
          expect(argsTo_fsWriteFile[1].indexOf(commitTemplate)).toBe 0

  describe "when 'stageChanges' option is true", ->
    it "calls git.add with update option set to true", ->
      setupMocks()
      GitCommit(repo, stageChanges: true).start().then ->
        expect(git.add).toHaveBeenCalledWith repo, update: true
