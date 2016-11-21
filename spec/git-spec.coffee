Path = require 'path'
Os = require 'os'
fs = require 'fs-plus'
git = require '../lib/git'
notifier = require '../lib/notifier'
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
        promise = git.cmd()
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
        spyOn(notifier, 'addError')
        waitsForPromise ->
          git.add(repo).then (result) ->
            fail "should have been rejected"
          .catch (error) ->
            expect(notifier.addError).toHaveBeenCalledWith 'git.add error'

  describe "git.reset", ->
    it "resets and unstages all files", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve true
      waitsForPromise ->
        git.reset(repo).then ->
          expect(git.cmd).toHaveBeenCalledWith ['reset', 'HEAD'], cwd: repo.getWorkingDirectory()

  describe "git.stagedFiles", ->
    it "returns an empty array when there are no staged files", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve ''
      waitsForPromise ->
        git.stagedFiles(repo)
        .then (files) ->
          expect(files.length).toEqual 0

    # it "returns an array with size 1 when there is a staged file", ->
    #   spyOn(git, 'cmd').andCallFake -> Promise.resolve("M\tsomefile.txt")
    #   waitsForPromise ->
    #     git.stagedFiles(repo)
    #     .then (files) ->
    #       expect(files.length).toEqual 1
    #
    # it "returns an array with size 4 when there are 4 staged files", ->
    #   spyOn(git, 'cmd').andCallFake ->
    #     Promise.resolve("M\tsomefile.txt\nA\tfoo.file\nD\tanother.text\nM\tagain.rb")
    #   waitsForPromise ->
    #     git.stagedFiles(repo)
    #     .then (files) ->
    #       expect(files.length).toEqual 4

  describe "git.unstagedFiles", ->
    it "returns an empty array when there are no unstaged files", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve ''
      waitsForPromise ->
        git.unstagedFiles(repo)
        .then (files) ->
          expect(files.length).toEqual 0

    ## Need a way to mock the terminal's first char identifier (\0)
    # it "returns an array with size 1 when there is an unstaged file", ->
    #   spyOn(git, 'cmd').andCallFake -> Promise.resolve "M\tsomefile.txt"
    #   waitsForPromise ->
    #     git.unstagedFiles(repo)
    #     .then (files) ->
    #       expect(files.length).toEqual 1
    #       expect(files[0].mode).toEqual 'M'
    #
    # it "returns an array with size 4 when there are 4 unstaged files", ->
    #   spyOn(git, 'cmd').andCallFake ->
    #     Promise.resolve("M\tsomefile.txt\nA\tfoo.file\nD\tanother.text\nM\tagain.rb")
    #   waitsForPromise ->
    #     git.unstagedFiles(repo)
    #     .then (files) ->
    #       expect(files.length).toEqual 4
    #       expect(files[1].mode).toEqual 'A'
    #       expect(files[3].mode).toEqual 'M'

  # describe "git.unstagedFiles and showUntracked: true", ->
  #   it "returns an array with size 1 when there is only an untracked file", ->
  #     spyOn(git, 'cmd').andCallFake ->
  #       if git.cmd.callCount is 2
  #         Promise.resolve "somefile.txt"
  #       else
  #         Promise.resolve ''
  #         waitsForPromise ->
  #           git.unstagedFiles(repo, showUntracked: true)
  #           .then (files) ->
  #             expect(files.length).toEqual 1
  #             expect(files[0].mode).toEqual '?'
  #
  #   it "returns an array of size 2 when there is an untracked file and an unstaged file", ->
  #     spyOn(git, 'cmd').andCallFake ->
  #       if git.cmd.callCount is 2
  #         Promise.resolve "untracked.txt"
  #       else
  #         Promise.resolve 'M\tunstaged.file'
  #     waitsForPromise ->
  #       git.unstagedFiles(repo, showUntracked: true)
  #       .then (files) ->
  #         expect(files.length).toEqual 2
  #         expect(files[0].mode).toEqual 'M'
  #         expect(files[1].mode).toEqual '?'

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
