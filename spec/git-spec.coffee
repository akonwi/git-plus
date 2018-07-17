Path = require 'path'
Os = require 'os'
fs = require 'fs-plus'
{GitRepository} = require 'atom'
git = require '../lib/git'
notifier = require('../lib/notifier')
ActivityLogger = require('../lib/activity-logger').default

{
  repo,
  pathToRepoFile,
  textEditor,
  commitPane,
  currentPane
} = require './fixtures'
pathToSubmoduleFile = Path.join Os.homedir(), "some/submodule/file"

mockSubmodule =
  getWorkingDirectory: -> Path.join Os.homedir(), "some/submodule"
  relativize: (path) -> "file" if path is pathToSubmoduleFile

mockRepoWithSubmodule = Object.create(repo)
mockRepoWithSubmodule.repo = {
  submoduleForPath: (path) ->
    mockSubmodule if path is pathToSubmoduleFile
}

describe "Git-Plus git module", ->
  describe "git.getConfig", ->
    describe "when a repo file path isn't specified", ->
      it "calls ::getConfigValue on the given instance of GitRepository", ->
        spyOn(repo, 'getConfigValue').andReturn 'value'
        expect(git.getConfig(repo, 'user.name')).toBe 'value'
        expect(repo.getConfigValue).toHaveBeenCalledWith 'user.name', repo.getWorkingDirectory()

    describe "when there is no value for a config key", ->
      it "returns null", ->
        spyOn(repo, 'getConfigValue').andReturn null
        expect(git.getConfig(repo, 'user.name')).toBe null

  describe "git.getRepo", ->
    it "returns a promise resolving to repository", ->
      spyOn(atom.project, 'getRepositories').andReturn [repo]
      waitsForPromise ->
        git.getRepo().then (actual) ->
          expect(actual.getWorkingDirectory()).toEqual repo.getWorkingDirectory()

  describe "git.dir", ->
    it "returns a promise resolving to absolute path of repo", ->
      spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
      spyOn(atom.project, 'getRepositories').andReturn [repo]
      git.dir().then (dir) ->
        expect(dir).toEqual repo.getWorkingDirectory()

  describe "git.getSubmodule", ->
    it "returns undefined when there is no submodule", ->
      expect(git.getSubmodule(pathToRepoFile)).toBe undefined

    it "returns a submodule when given file is in a submodule of a project repo", ->
      spyOn(atom.project, 'getRepositories').andCallFake -> [mockRepoWithSubmodule]
      expect(git.getSubmodule(pathToSubmoduleFile).getWorkingDirectory()).toEqual mockSubmodule.getWorkingDirectory()

  describe "git.relativize", ->
    it "returns relativized filepath for files in repo", ->
      spyOn(atom.project, 'getRepositories').andCallFake -> [repo, mockRepoWithSubmodule]
      expect(git.relativize pathToRepoFile).toBe 'directory/file'
      expect(git.relativize pathToSubmoduleFile).toBe "file"

  describe "git.cmd", ->
    it "returns a promise", ->
      waitsForPromise ->
        promise = git.cmd([])
        expect(promise.catch).toBeDefined()
        expect(promise.then).toBeDefined()
        promise.catch (output) ->
          expect(output).toContain('usage')

    it "returns a promise that is fulfilled with stdout on success", ->
      waitsForPromise ->
        git.cmd(['--version']).then (output) ->
          expect(output).toContain('git version')

    it "returns a promise that is rejected with stderr on failure", ->
      waitsForPromise ->
        git.cmd(['help', '--bogus-option']).catch (output) ->
          expect(output).toContain('unknown option')

    it "returns a promise that is fulfilled with stderr on success", ->
      initDir = 'git-plus-test-dir' + Math.random()
      cloneDir = initDir + '-clone'
      waitsForPromise ->
        # TODO: Use something that doesn't require permissions and can run within atom
        git.cmd(['init', initDir]).then () ->
          git.cmd(['clone', '--progress', initDir, cloneDir])
        .then (output) ->
          fs.removeSync(initDir)
          fs.removeSync(cloneDir)
          expect(output).toContain('Cloning')

  describe "git.add", ->
    it "calls git.cmd with ['add', '--all', {fileName}]", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve true
      waitsForPromise ->
        git.add(repo, file: pathToSubmoduleFile).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--all', pathToSubmoduleFile], cwd: repo.getWorkingDirectory())

    it "calls git.cmd with ['add', '--all', '.'] when no file is specified", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve true
      waitsForPromise ->
        git.add(repo).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--all', '.'], cwd: repo.getWorkingDirectory())

    it "calls git.cmd with ['add', '--update'...] when update option is true", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve true
      waitsForPromise ->
        git.add(repo, update: true).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--update', '.'], cwd: repo.getWorkingDirectory())

    describe "when it fails", ->
      it "notifies of failure", ->
        spyOn(git, 'cmd').andReturn Promise.reject 'git.add error'
        spyOn(ActivityLogger, 'record')
        waitsForPromise ->
          git.add(repo).then (result) ->
            fail "should have been rejected"
          .catch (error) ->
            expect(ActivityLogger.record.mostRecentCall.args[0].failed).toBe(true)

  describe "git.reset", ->
    it "resets and unstages all files", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve true
      waitsForPromise ->
        git.reset(repo).then ->
          expect(git.cmd).toHaveBeenCalledWith ['reset', 'HEAD'], cwd: repo.getWorkingDirectory()

  describe "getting staged/unstaged files", ->
    workingDirectory = Path.join(Os.homedir(), 'fixture-repo')
    file = Path.join(workingDirectory, 'fake.file')
    repository = null

    beforeEach ->
      fs.writeFileSync file, 'foobar'
      waitsForPromise -> git.cmd(['init'], cwd: workingDirectory)
      waitsForPromise -> git.cmd(['config', 'user.useconfigonly', 'false'], cwd: workingDirectory)
      waitsForPromise -> git.cmd(['add', file], cwd: workingDirectory)
      waitsForPromise -> git.cmd(['commit', '--allow-empty', '--allow-empty-message', '-m', ''], cwd: workingDirectory)
      runs -> repository = GitRepository.open(workingDirectory)

    afterEach ->
      fs.removeSync workingDirectory
      repository.destroy()

    describe "git.stagedFiles", ->
      it "returns an empty array when there are no staged files", ->
        git.stagedFiles(repository)
        .then (files) -> expect(files.length).toEqual 0

      it "returns a non-empty array when there are staged files", ->
        fs.writeFileSync file, 'some stuff'
        waitsForPromise -> git.cmd(['add', 'fake.file'], cwd: workingDirectory)
        waitsForPromise ->
          git.stagedFiles(repository)
          .then (files) ->
            expect(files.length).toEqual 1
            expect(files[0].mode).toEqual 'M'
            expect(files[0].path).toEqual 'fake.file'
            expect(files[0].staged).toBe true

    describe "git.unstagedFiles", ->
      it "returns an empty array when there are no unstaged files", ->
        git.unstagedFiles(repository)
        .then (files) -> expect(files.length).toEqual 0

      it "returns a non-empty array when there are unstaged files", ->
        fs.writeFileSync file, 'some stuff'
        waitsForPromise -> git.cmd(['reset'], cwd: workingDirectory)
        waitsForPromise ->
          git.unstagedFiles(repository)
          .then (files) ->
            expect(files.length).toEqual 1
            expect(files[0].mode).toEqual 'M'
            expect(files[0].staged).toBe false

    describe "git.unstagedFiles(showUntracked: true)", ->
      it "returns an array with size 1 when there is only an untracked file", ->
        newFile = Path.join(workingDirectory, 'another.file')
        fs.writeFileSync newFile, 'this is untracked'
        waitsForPromise ->
          git.unstagedFiles(repository, showUntracked: true)
          .then (files) ->
            expect(files.length).toEqual 1
            expect(files[0].mode).toEqual '?'

  describe "git.status", ->
    it "calls git.cmd with 'status' as the first argument", ->
      spyOn(git, 'cmd').andCallFake ->
        args = git.cmd.mostRecentCall.args
        if args[0][0] is 'status'
          Promise.resolve true
      git.status(repo).then -> expect(true).toBeTruthy()

  describe "git.refresh", ->
    describe "when no arguments are passed", ->
      it "calls repo.refreshStatus for each repo in project", ->
        spyOn(atom.project, 'getRepositories').andCallFake -> [ repo ]
        spyOn(repo, 'refreshStatus')
        git.refresh()
        expect(repo.refreshStatus).toHaveBeenCalled()

    describe "when a GitRepository object is passed", ->
      it "calls repo.refreshStatus for each repo in project", ->
        spyOn(repo, 'refreshStatus')
        git.refresh repo
        expect(repo.refreshStatus).toHaveBeenCalled()

  describe "git.diff", ->
    it "calls git.cmd with ['diff', '-p', '-U1'] and the file path", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve "string"
      git.diff(repo, pathToRepoFile)
      expect(git.cmd).toHaveBeenCalledWith ['diff', '-p', '-U1', pathToRepoFile], cwd: repo.getWorkingDirectory()
