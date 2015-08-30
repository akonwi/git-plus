git = require '../../lib/git'
{repo, pathToRepoFile} = require '../fixtures'
{gitBranches} = require '../../lib/models/git-branch'

describe "GitBranch", ->
  describe ".branches", ->
    beforeEach ->
      spyOn(git, 'cmd').andReturn Promise.resolve 'branch1\nbranch2'
      spyOn(atom.workspace, 'addModalPanel').andCallThrough()
      waitsForPromise -> gitBranches(repo)

    it "displays a list of the repo's branches", ->
      expect(git.cmd).toHaveBeenCalledWith ['branch'], cwd: repo.getWorkingDirectory()
      expect(atom.workspace.addModalPanel).toHaveBeenCalled()
