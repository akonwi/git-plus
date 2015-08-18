fs = require 'fs-plus'
git = require '../lib/git'
Path = require 'flavored-path'

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
    it "stages a file", ->
      waitsForPromise ->
        repo = git.getSubmodule(pathToSubmoduleFile)
        fs.writeFileSync pathToSubmoduleFile, 'foofi'
        git.add(repo, file: pathToSubmoduleFile).then (success) -> expect(success).toBe true

  describe "git.stagedFiles", ->
    it "returns an empty array when there are no staged files", ->
      waitsForPromise ->
        git.stagedFiles(git.getSubmodule(pathToSubmoduleFile))
        .then (files) ->
          expect(files.length).toEqual 0

    it "returns an array with size 1 when there is a staged file", ->
      waitsForPromise ->
        git.stagedFiles(git.getSubmodule(pathToSubmoduleFile))
        .then (files) ->
           expect(files.length).toEqual 1
