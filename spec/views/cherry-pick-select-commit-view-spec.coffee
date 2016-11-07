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
    @view.selectNextItemView()
    @view.confirmSelection()
    @view.find('.btn-pick-button').click()
    expect(git.cmd).toHaveBeenCalledWith ['cherry-pick', 'commit1', 'commit2'], cwd: repo.getWorkingDirectory()
