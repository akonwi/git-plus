{repo} = require '../fixtures'
git = require '../../lib/git'
GitDiffBranchFiles = require '../../lib/models/git-diff-branch-files'

describe "GitDiffBranchFiles", ->
  beforeEach ->
    spyOn(git, 'cmd').andReturn Promise.resolve 'foobar'

  it "calls git.status", ->
    GitDiffBranchFiles(repo).then (data) ->
      expect(git.cmd).toHaveBeenCalledWith ['branch', '--no-color'], cwd: repo.getWorkingDirectory()

  it "creates a new DiffBranchFileChoose", ->
    GitDiffBranchFiles(repo).then (data) ->
      expect(data).toBeDefined()
