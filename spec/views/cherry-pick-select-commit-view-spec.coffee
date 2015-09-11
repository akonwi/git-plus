git = require '../../lib/git'
{repo} = require '../fixtures'
CherryPickSelectCommits = require '../../lib/views/cherry-pick-select-commits-view'

describe "CherryPickSelectCommits view", ->
  beforeEach ->
    @view = new CherryPickSelectCommits(repo, ['commit1', 'commit2'])

  it "displays a list of commits", ->
    expect(@view.items.length).toBe 2

  it "calls git.cmd with 'cherry-pick' and the selected commits", ->
    spyOn(git, 'cmd').andReturn Promise.resolve 'success'
    @view.confirmSelection()
    @view.find('.btn-pick-button').click()
  #   expectedArgs = [
  #     'log'
  #     '--cherry-pick'
  #     '-z'
  #     '--format=%H%n%an%n%ar%n%s'
  #     "currentHead...head1"
  #   ]
    expect(git.cmd).toHaveBeenCalledWith ['cherry-pick', 'commit1'], cwd: repo.getWorkingDirectory()
