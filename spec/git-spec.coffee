fs = require 'fs-plus'
Path = require 'flavored-path'
git = require '../lib/git'
mock = require './mock'

pathToRepoFile = Path.get "~/.atom/packages/git-plus/lib/git.coffee"
pathToSubmoduleFile = Path.get "~/.atom/packages/git-plus/spec/foo/foo.txt"

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
        repo = git.getSubmodule(pathToSubmoduleFile)
        git.add(repo, file: pathToSubmoduleFile).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--all', pathToSubmoduleFile], cwd: repo.getWorkingDirectory())

    it "calls git.cmd with ['add', '--all', '.'] when no file is specified", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve true
      waitsForPromise ->
        repo = git.getSubmodule(pathToSubmoduleFile)
        git.add(repo).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--all', '.'], cwd: repo.getWorkingDirectory())

    it "calls git.cmd with ['add', '--update'...] when update option is true", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve true
      waitsForPromise ->
        repo = git.getSubmodule(pathToSubmoduleFile)
        git.add(repo, update: true).then (success) ->
          expect(git.cmd).toHaveBeenCalledWith(['add', '--update', '.'], cwd: repo.getWorkingDirectory())

  describe "git.reset", ->
    it "resets and unstages all files", ->
      spyOn(git, 'cmd').andCallFake () -> Promise.resolve true
      waitsForPromise ->
        repo = git.getSubmodule(pathToSubmoduleFile)
        git.reset(repo).then () ->
          expect(git.cmd).toHaveBeenCalledWith ['reset', 'HEAD'], cwd: repo.getWorkingDirectory()

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
