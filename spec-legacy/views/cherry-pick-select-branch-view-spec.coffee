git = require '../../lib/git'
{repo} = require '../fixtures'
CherryPickSelectBranch = require '../../lib/views/cherry-pick-select-branch-view'

describe "CherryPickSelectBranch view", ->
  beforeEach ->
    @view = new CherryPickSelectBranch(repo, ['head1', 'head2'], 'currentHead')

  it "displays a list of branches", ->
    expect(@view.items.length).toBe 2

  it "calls git.cmd to get commits between currentHead and selected head", ->
    spyOn(git, 'cmd').andReturn Promise.resolve 'heads'
    @view.confirmSelection()
    expectedArgs = [
      'log'
      '--cherry-pick'
      '-z'
      '--format=%H%n%an%n%ar%n%s'
      "currentHead...head1"
    ]
    expect(git.cmd).toHaveBeenCalledWith expectedArgs, cwd: repo.getWorkingDirectory()
