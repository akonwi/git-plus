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
        git.dir().catch (error) -> expect(erro).toEqual 'No repos found'
        # .then (dir) ->
        #   expect(dir).toContain 'git-plus'
        #   expect(dir).toContain 'akonwi'

  # describe "git.getSubmodule", ->
  #   it "returns null when there is no submodule", ->
  #     expect(git.getSubmodule(atom.workspace.getActiveTextEditor().getPath())).toEqual null
