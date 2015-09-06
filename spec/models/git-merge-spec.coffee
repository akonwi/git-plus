{repo} = require '../fixtures'
git = require '../../lib/git'
GitMerge = require '../../lib/models/git-merge'

describe "GitMerge", ->
  it "calls git.cmd with 'branch'", ->
    spyOn(git, 'cmd').andReturn Promise.resolve ''
    GitMerge(repo)
    expect(git.cmd).toHaveBeenCalledWith ['branch'], cwd: repo.getWorkingDirectory()
