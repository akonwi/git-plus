{repo} = require '../fixtures'
git = require '../../lib/git'
GitDiffBranches = require '../../lib/models/git-diff-branches'

describe "GitDiffBranches", ->
  beforeEach ->
    spyOn(git, 'cmd').andReturn Promise.resolve 'foobar'

  it "calls git.status", ->
    GitDiffBranches(repo).then (data) ->
      expect(git.cmd).toHaveBeenCalledWith ['branch', '--no-color'], cwd: repo.getWorkingDirectory()

  it "creates a new DiffBranchView", ->
    GitDiffBranches(repo).then (data) ->
      expect(data).toBeDefined()
