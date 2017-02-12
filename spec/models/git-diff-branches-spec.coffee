quibble = require 'quibble'
{repo} = require '../fixtures'
git = require '../../lib/git'

branches = 'foobar'

describe "GitDiffBranches", ->
  GitDiffBranches = require '../../lib/models/git-diff-branches'

  beforeEach ->
    spyOn(git, 'cmd').andReturn Promise.resolve(branches)

  it "gets the branches", ->
    GitDiffBranches(repo)
    expect(git.cmd).toHaveBeenCalledWith ['branch', '--no-color'], cwd: repo.getWorkingDirectory()

  it "creates a DiffBranchView", ->
    GitDiffBranches(repo).then (view) -> expect(view instanceof DiffBranchView).toBe true
