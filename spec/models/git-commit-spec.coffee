os = require 'os'
Path = require 'path'
quibble = require 'quibble'
fs = require 'fs-plus'
{GitRepository} = require 'atom'
git = require '../../lib/git'
notifier = require '../../lib/notifier'

commentChar = '%'
workingDirectory = Path.join(os.homedir(), 'fixture-repo')
commitFilePath = Path.join(workingDirectory, '/.git/COMMIT_EDITMSG')
file = Path.join(workingDirectory, 'fake.file')
repo = null

describe "GitCommit", ->
  GitPush = quibble '../../lib/models/git-push', jasmine.createSpy('GitPush')
  GitCommit = require '../../lib/models/git-commit'
  beforeEach ->
    fs.writeFileSync file, 'foobar'
    waitsForPromise -> git.cmd(['init'], cwd: workingDirectory)
    waitsForPromise -> git.cmd(['config', 'user.useconfigonly', 'false'], cwd: workingDirectory)
    waitsForPromise -> git.cmd(['config', 'core.commentchar', commentChar], cwd: workingDirectory)
    waitsForPromise -> git.cmd(['add', file], cwd: workingDirectory)
    waitsForPromise -> git.cmd(['commit', '--allow-empty', '--allow-empty-message', '-m', ''], cwd: workingDirectory)
    waitsForPromise -> git.cmd(['tag', '-a', '-m', '', 'ROOT'], cwd: workingDirectory)
    runs -> repo = GitRepository.open(workingDirectory)

  afterEach ->
    fs.removeSync workingDirectory
    repo.destroy()

  describe "a regular commit", ->
    beforeEach ->
      fs.writeFileSync file, Math.random()
      waitsForPromise -> git.cmd(['add', file], cwd: workingDirectory)
      waitsForPromise -> GitCommit(repo)

    it "uses the commentchar from git configs", ->
      editor = atom.workspace.paneForURI(commitFilePath).itemForURI(commitFilePath)
      expect(editor.getText().trim()[0]).toBe commentChar

    it "gets staged files", ->
      editor = atom.workspace.paneForURI(commitFilePath).itemForURI(commitFilePath)
      expect(editor.getText()).toContain 'modified:   fake.file'

    it "makes a commit when the commit file is saved and closes the textEditor", ->
      spyOn(notifier, 'addSuccess')
      editor = atom.workspace.paneForURI(commitFilePath).itemForURI(commitFilePath)
      spyOn(editor, 'destroy').andCallThrough()
      editor.setText 'this is a commit'
      editor.save()
      log = null
      waitsFor -> editor.destroy.callCount > 0
      waitsForPromise -> log = git.cmd(['whatchanged', '-1'], cwd: workingDirectory)
      runs ->
        expect(notifier.addSuccess).toHaveBeenCalled()
        log.then (l) -> expect(l).toContain 'this is a commit'

    it "cancels the commit on textEditor destroy", ->
      editor = atom.workspace.paneForURI(commitFilePath).itemForURI(commitFilePath)
      editor.destroy()

  describe "when commit.template config is set", ->
    it "pre-populates the commit with the template message", ->
      templateFile = Path.join(os.tmpdir(), 'commit-template')
      fs.writeFileSync templateFile, 'foobar'
      waitsForPromise -> git.cmd(['config', 'commit.template', templateFile], cwd: workingDirectory)
      fs.writeFileSync file, Math.random()
      waitsForPromise -> git.cmd(['add', file], cwd: workingDirectory)
      waitsForPromise -> GitCommit(repo)
      runs ->
        editor = atom.workspace.paneForURI(commitFilePath).itemForURI(commitFilePath)
        expect(editor.getText().startsWith('foobar')).toBe true
        git.cmd(['config', '--unset', 'commit.template'], cwd: workingDirectory)
        fs.removeSync(templateFile)

    describe "when the template file can't be found", ->
      it "notifies user", ->
        spyOn(notifier, 'addError')
        templateFile = Path.join(os.tmpdir(), 'commit-template')
        waitsForPromise -> git.cmd(['config', 'commit.template', templateFile], cwd: workingDirectory)
        fs.writeFileSync file, Math.random()
        waitsForPromise -> git.cmd(['add', file], cwd: workingDirectory)
        waitsForPromise -> GitCommit(repo).catch -> Promise.resolve()
        runs ->
          expect(notifier.addError).toHaveBeenCalledWith "Your configured commit template file can't be found."

  describe "when 'stageChanges' option is true", ->
    beforeEach ->
      fs.writeFileSync file, Math.random()
      waitsForPromise -> GitCommit(repo, stageChanges: true)

    it "stages modified and tracked files", ->
      editor = atom.workspace.paneForURI(commitFilePath).itemForURI(commitFilePath)
      expect(editor.getText()).toContain 'modified:   fake.file'

  describe "a failing commit", ->
    beforeEach ->
      fs.writeFileSync file, Math.random()
      waitsForPromise -> git.cmd(['add', file], cwd: workingDirectory)
      waitsForPromise -> GitCommit(repo)

    it "notifies of error and closes commit pane", ->
      editor = atom.workspace.paneForURI(commitFilePath).itemForURI(commitFilePath)
      spyOn(editor, 'destroy').andCallThrough()
      spyOn(notifier, 'addError')
      spyOn(git, 'cmd').andReturn Promise.reject()
      editor.save()
      waitsFor -> notifier.addError.callCount > 0
      runs ->
        expect(notifier.addError).toHaveBeenCalled()
        expect(editor.destroy).toHaveBeenCalled()

  describe "when the verbose commit setting is true", ->
    beforeEach ->
      atom.config.set "git-plus.commits.verboseCommits", true
      fs.writeFileSync file, Math.random()
      waitsForPromise -> git.cmd(['add', file], cwd: workingDirectory)
      waitsForPromise -> GitCommit(repo)

    it "puts the diff in the commit file", ->
      editor = atom.workspace.paneForURI(commitFilePath).itemForURI(commitFilePath)
      waitsForPromise ->
        git.cmd(['diff', '--color=never', '--staged'], cwd: workingDirectory)
        .then (diff) ->
          expect(editor.getText()).toContain diff

  describe "when the `git-plus.general.openInPane` setting is true", ->
    beforeEach ->
      atom.config.set 'git-plus.general.openInPane', true
      atom.config.set 'git-plus.general.splitPane', 'Right'
      fs.writeFileSync file, Math.random()
      waitsForPromise -> git.cmd(['add', file], cwd: workingDirectory)
      waitsForPromise -> GitCommit(repo)

    it "closes the created pane on finish", ->
      pane = atom.workspace.paneForURI(commitFilePath)
      spyOn(pane, 'destroy').andCallThrough()
      pane.itemForURI(commitFilePath).save()
      waitsFor -> pane.destroy.callCount > 0
      runs -> expect(pane.destroy).toHaveBeenCalled()

  describe "when 'andPush' option is true", ->
    beforeEach ->
      fs.writeFileSync file, Math.random()
      waitsForPromise -> git.cmd(['add', file], cwd: workingDirectory)
      waitsForPromise -> GitCommit(repo, andPush: true)

    it "tries to push after a successful commit", ->
      editor = atom.workspace.paneForURI(commitFilePath).itemForURI(commitFilePath)
      spyOn(editor, 'destroy').andCallThrough()
      editor.setText 'blah blah'
      editor.save()
      waitsFor -> editor.destroy.callCount > 0
      runs -> expect(GitPush).toHaveBeenCalledWith repo
