git = require '../lib/git'
Path = require 'flavored-path'

pathToRepoFile = Path.get "~/.atom/packages/git-plus/lib/git.coffee"
pathToSubmoduleFile = Path.get "~/.atom/packages/git-plus/spec/foo/foo.txt"

describe "Git-Plus git module", ->
  describe "git.getRepo", ->
    it "returns a promise", ->
      waitsForPromise ->
        git.getRepo().then (repo) ->
          expect(repo.getWorkingDirectory()).toContain 'git-plus'

  describe "git.dir", ->
    it "returns a promise", ->
      waitsForPromise ->
        git.dir().then (dir) ->
          expect(dir).toContain 'git-plus'

  describe "git.getSubmodule", ->
    it "returns undefined when there is no submodule", ->
      expect(git.getSubmodule(pathToRepoFile)).toBe undefined

    it "returns a submodule when given file is in a submodule of a project repo", ->
      expect(git.getSubmodule(pathToSubmoduleFile)).toBeTruthy()
