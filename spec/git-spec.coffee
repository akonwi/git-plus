fs = require 'fs-plus'
Path = require 'flavored-path'
git = require '../lib/git'
notifier = require '../lib/notifier'
{
  repo,
  pathToRepoFile,
  textEditor,
  commitPane,
  currentPane
} = require './fixtures'
pathToSubmoduleFile = Path.get "~/some/submodule/file"

mockRepo =
  getWorkingDirectory: -> Path.get "~/some/repository"
  refreshStatus: -> undefined
  relativize: (path) -> "directory/file" if path is pathToRepoFile
  repo:
    submoduleForPath: (path) -> undefined

mockSubmodule =
  getWorkingDirectory: -> Path.get "~/some/submodule"
  relativize: (path) -> "file" if path is pathToSubmoduleFile

mockRepoWithSubmodule = Object.create(mockRepo)
mockRepoWithSubmodule.repo = {
  submoduleForPath: (path) ->
    mockSubmodule if path is pathToSubmoduleFile
}

describe "Git-Plus git module", ->
  describe "git.getConfig", ->
    args = ['config', '--get', 'user.name']

    describe "when a repo file path isn't specified", ->
      it "spawns a command querying git for the given global setting", ->
        spyOn(git, 'cmd').andReturn Promise.resolve 'akonwi'
        waitsForPromise ->
          git.getConfig('user.name')
        runs ->
          expect(git.cmd).toHaveBeenCalledWith args, cwd: Path.get('~')

    describe "when a repo file path is specified", ->
      it "checks for settings in that repo", ->
        spyOn(git, 'cmd').andReturn Promise.resolve 'akonwi'
        waitsForPromise ->
          git.getConfig('user.name', repo.getWorkingDirectory())
        runs ->
          expect(git.cmd).toHaveBeenCalledWith args, cwd: repo.getWorkingDirectory()

    describe "when the command fails without an error message", ->
      it "resolves to ''", ->
        spyOn(git, 'cmd').andReturn Promise.reject ''
        waitsForPromise ->
          git.getConfig('user.name', repo.getWorkingDirectory()).then (result) ->
            expect(result).toEqual('')
        runs ->
          expect(git.cmd).toHaveBeenCalledWith args, cwd: repo.getWorkingDirectory()

    describe "when the command fails with an error message", ->
      it "rejects with the error message", ->
        spyOn(git, 'cmd').andReturn Promise.reject 'getConfig error'
        spyOn(notifier, 'addError')
        waitsForPromise ->
          git.getConfig('user.name', 'bad working dir').then (result) ->
            fail "should have been rejected"
          .catch (error) ->
            expect(notifier.addError).toHaveBeenCalledWith 'getConfig error'

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
      expect(git.getSubmodule(pathToSubmoduleFile).getWorkingDirectory()).toEqual Path.get "~/some/submodule"

  describe "git.relativize", ->
    it "returns relativized filepath for files in repo", ->
      spyOn(atom.project, 'getRepositories').andCallFake -> [mockRepo, mockRepoWithSubmodule]
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
        git.add(mockRepo, file: pathToSubmoduleFile).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--all', pathToSubmoduleFile], cwd: mockRepo.getWorkingDirectory())

    it "calls git.cmd with ['add', '--all', '.'] when no file is specified", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve true
      waitsForPromise ->
        git.add(mockRepo).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--all', '.'], cwd: mockRepo.getWorkingDirectory())

    it "calls git.cmd with ['add', '--update'...] when update option is true", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve true
      waitsForPromise ->
        git.add(mockRepo, update: true).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--update', '.'], cwd: mockRepo.getWorkingDirectory())

  describe "git.reset", ->
    it "resets and unstages all files", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve true
      waitsForPromise ->
        git.reset(mockRepo).then ->
          expect(git.cmd).toHaveBeenCalledWith ['reset', 'HEAD'], cwd: mockRepo.getWorkingDirectory()

  describe "git.stagedFiles", ->
    it "returns an empty array when there are no staged files", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve ''
      waitsForPromise ->
        git.stagedFiles(mockRepo)
        .then (files) ->
          expect(files.length).toEqual 0

    # it "returns an array with size 1 when there is a staged file", ->
    #   spyOn(git, 'cmd').andCallFake -> Promise.resolve("M\tsomefile.txt")
    #   waitsForPromise ->
    #     git.stagedFiles(mockRepo)
    #     .then (files) ->
    #       expect(files.length).toEqual 1
    #
    # it "returns an array with size 4 when there are 4 staged files", ->
    #   spyOn(git, 'cmd').andCallFake ->
    #     Promise.resolve("M\tsomefile.txt\nA\tfoo.file\nD\tanother.text\nM\tagain.rb")
    #   waitsForPromise ->
    #     git.stagedFiles(mockRepo)
    #     .then (files) ->
    #       expect(files.length).toEqual 4

  describe "git.unstagedFiles", ->
    it "returns an empty array when there are no unstaged files", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve ''
      waitsForPromise ->
        git.unstagedFiles(mockRepo)
        .then (files) ->
          expect(files.length).toEqual 0

    ## Need a way to mock the terminal's first char identifier (\0)
    # it "returns an array with size 1 when there is an unstaged file", ->
    #   spyOn(git, 'cmd').andCallFake -> Promise.resolve "M\tsomefile.txt"
    #   waitsForPromise ->
    #     git.unstagedFiles(mockRepo)
    #     .then (files) ->
    #       expect(files.length).toEqual 1
    #       expect(files[0].mode).toEqual 'M'
    #
    # it "returns an array with size 4 when there are 4 unstaged files", ->
    #   spyOn(git, 'cmd').andCallFake ->
    #     Promise.resolve("M\tsomefile.txt\nA\tfoo.file\nD\tanother.text\nM\tagain.rb")
    #   waitsForPromise ->
    #     git.unstagedFiles(mockRepo)
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
  #           git.unstagedFiles(mockRepo, showUntracked: true)
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
  #       git.unstagedFiles(mockRepo, showUntracked: true)
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
      git.status(mockRepo).then -> expect(true).toBeTruthy()

  describe "git.refresh", ->
    it "calls git.cmd with 'add' and '--refresh' arguments for each repo in project", ->
      spyOn(git, 'cmd').andCallFake ->
        args = git.cmd.mostRecentCall.args[0]
        expect(args[0]).toBe 'add'
        expect(args[1]).toBe '--refresh'
      spyOn(mockRepo, 'getWorkingDirectory').andCallFake ->
        expect(mockRepo.getWorkingDirectory.callCount).toBe 1
      git.refresh()

    it "calls repo.refreshStatus for each repo in project", ->
      spyOn(atom.project, 'getRepositories').andCallFake -> [ mockRepo ]
      spyOn(mockRepo, 'refreshStatus')
      spyOn(git, 'cmd').andCallFake -> undefined
      git.refresh()
      expect(mockRepo.refreshStatus.callCount).toBe 1

  describe "git.diff", ->
    it "calls git.cmd with ['diff', '-p', '-U1'] and the file path", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve "string"
      git.diff(mockRepo, pathToRepoFile)
      expect(git.cmd).toHaveBeenCalledWith ['diff', '-p', '-U1', pathToRepoFile], cwd: mockRepo.getWorkingDirectory()
