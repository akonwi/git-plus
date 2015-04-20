git = require '../lib/git'

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
          expect(dir).toContain 'akonwi'

  describe "git.getSubmodule", ->
    it "returns null when there is no submodule", ->
      expect(git.getSubmodule("~/.atom/packages/git-plus/lib/git.coffee")).toBeFalsy()
