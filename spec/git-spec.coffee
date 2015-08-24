fs = require 'fs-plus'
Path = require 'flavored-path'
git = require '../lib/git'
mock = require './mock'

pathToRepoFile = Path.get "~/.atom/packages/git-plus/lib/git.coffee"
pathToSubmoduleFile = Path.get "~/.atom/packages/git-plus/spec/foo/foo.txt"

mockRepo = {
  getWorkingDirectory: () -> 'dir'
  refreshStatus: () -> undefined
}

describe "Git-Plus git module", ->
  describe "git.getRepo", ->
    it "returns a promise resolving to repository", ->
      waitsForPromise ->
        git.getRepo().then (repo) ->
          expect(repo.getWorkingDirectory()).toContain 'git-plus'

  describe "git.dir", ->
    it "returns a promise resolving to absolute path of repo", ->
      waitsForPromise ->
        git.dir().then (dir) ->
          expect(dir).toContain 'git-plus'

  describe "git.getSubmodule", ->
    it "returns undefined when there is no submodule", ->
      expect(git.getSubmodule(pathToRepoFile)).toBe undefined

    it "returns a submodule when given file is in a submodule of a project repo", ->
      expect(git.getSubmodule(pathToSubmoduleFile)).toBeTruthy()

  describe "git.relativize", ->
    it "returns relativized filepath for files in repo", ->
      expect(git.relativize pathToRepoFile).toBe 'lib/git.coffee'
      expect(git.relativize pathToSubmoduleFile).toBe 'foo.txt'

  describe "git.cmd", ->
    it "returns a promise", ->
      waitsForPromise ->
        git.cmd().then () -> expect(true).toBeTruthy()

  describe "git.add", ->
    it "calls git.cmd with ['add', '--all', {fileName}]", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve true
      waitsForPromise ->
        git.add(mockRepo, file: pathToSubmoduleFile).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--all', pathToSubmoduleFile], cwd: mockRepo.getWorkingDirectory())

    it "calls git.cmd with ['add', '--all', '.'] when no file is specified", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve true
      waitsForPromise ->
        git.add(mockRepo).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--all', '.'], cwd: mockRepo.getWorkingDirectory())

    it "calls git.cmd with ['add', '--update'...] when update option is true", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve true
      waitsForPromise ->
        git.add(mockRepo, update: true).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--update', '.'], cwd: mockRepo.getWorkingDirectory())

  describe "git.reset", ->
    it "resets and unstages all files", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve true
      waitsForPromise ->
        git.reset(mockRepo).then () ->
          expect(git.cmd).toHaveBeenCalledWith ['reset', 'HEAD'], cwd: mockRepo.getWorkingDirectory()

  describe "git.stagedFiles", ->
    it "returns an empty array when there are no staged files", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve ''
      waitsForPromise ->
        git.stagedFiles(git.getSubmodule(pathToSubmoduleFile))
        .then (files) ->
          expect(files.length).toEqual 0

    it "returns an array with size 1 when there is a staged file", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve("M\tsomefile.txt")
      waitsForPromise ->
        git.stagedFiles(git.getSubmodule(pathToSubmoduleFile))
        .then (files) ->
          expect(files.length).toEqual 1

    it "returns an array with size 4 when there are 4 staged files", ->
      spyOn(git, 'cmd').andCallFake () ->
        Promise.resolve("M\tsomefile.txt\nA\tfoo.file\nD\tanother.text\nM\tagain.rb")
      waitsForPromise ->
        git.stagedFiles(git.getSubmodule(pathToSubmoduleFile))
        .then (files) ->
          expect(files.length).toEqual 4

  describe "git.unstagedFiles", ->
    it "returns an empty array when there are no unstaged files", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve ''
      waitsForPromise ->
        git.unstagedFiles(git.getSubmodule(pathToSubmoduleFile))
        .then (files) ->
          expect(files.length).toEqual 0

    it "returns an array with size 1 when there is an unstaged file", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve "M\tsomefile.txt"
      waitsForPromise ->
        git.unstagedFiles(git.getSubmodule(pathToSubmoduleFile))
        .then (files) ->
          expect(files.length).toEqual 1
          expect(files[0].mode).toEqual 'M'

    it "returns an array with size 4 when there are 4 unstaged files", ->
      spyOn(git, 'cmd').andCallFake () ->
        Promise.resolve("M\tsomefile.txt\nA\tfoo.file\nD\tanother.text\nM\tagain.rb")
      waitsForPromise ->
        git.unstagedFiles(git.getSubmodule(pathToSubmoduleFile))
        .then (files) ->
          expect(files.length).toEqual 4
          expect(files[1].mode).toEqual 'A'
          expect(files[3].mode).toEqual 'M'

    describe "git.unstagedFiles and showUntracked: true", ->
      it "returns an array with size 1 when there is only an untracked file", ->
        spyOn(git, 'cmd').andCallFake () ->
          if git.cmd.callCount is 2
            Promise.resolve "somefile.txt"
          else
            Promise.resolve ''
        waitsForPromise ->
          git.unstagedFiles(git.getSubmodule(pathToSubmoduleFile), showUntracked: true)
          .then (files) ->
            expect(files.length).toEqual 1
            expect(files[0].mode).toEqual '?'

      it "returns an array of size 2 when there is an untracked file and an unstaged file", ->
        spyOn(git, 'cmd').andCallFake () ->
          if git.cmd.callCount is 2
            Promise.resolve "untracked.txt"
          else
            Promise.resolve 'M\tunstaged.file'
        waitsForPromise ->
          git.unstagedFiles(git.getSubmodule(pathToSubmoduleFile), showUntracked: true)
          .then (files) ->
            expect(files.length).toEqual 2
            expect(files[0].mode).toEqual 'M'
            expect(files[1].mode).toEqual '?'

    describe "git.status", ->
      it "calls git.cmd with 'status' as the first argument", ->
        spyOn(git, 'cmd').andCallFake () ->
          args = git.cmd.mostRecentCall.args
          if args[0][0] is 'status'
            Promise.resolve true
        git.status(git.getSubmodule(pathToSubmoduleFile)).then () -> expect(true).toBeTruthy()

    describe "git.refresh", ->
      it "calls git.cmd with 'add' and '--refresh' arguments for each repo in project", ->
        spyOn(git, 'cmd').andCallFake () ->
          args = git.cmd.mostRecentCall.args[0]
          expect(args[0]).toBe 'add'
          expect(args[1]).toBe '--refresh'
        spyOn(mockRepo, 'getWorkingDirectory').andCallFake () ->
          expect(mockRepo.getWorkingDirectory.callCount).toBe 1
        git.refresh()

      it "calls repo.refreshStatus for each repo in project", ->
        spyOn(atom.project, 'getRepositories').andCallFake () -> [ mockRepo ]
        spyOn(mockRepo, 'refreshStatus')
        spyOn(git, 'cmd').andCallFake () -> undefined
        git.refresh()
        expect(mockRepo.refreshStatus.callCount).toBe 1

    describe "git.diff", ->
      it "calls git.cmd with ['diff', '-p', '-U1'] and the file path", ->
        spyOn(git, 'cmd').andCallFake () ->
          args = git.cmd.mostRecentCall.args[0]
          if args[0] is 'diff' and args[1] is '-p' and args[2] is '-U1' and args[3] is pathToSubmoduleFile
            Promise.resolve(true)
        git.diff(git.getSubmodule(pathToSubmoduleFile), pathToSubmoduleFile)
