git = require '../../lib/git'
{repo} = require '../fixtures'
BranchListView = require '../../lib/views/branch-list-view'

describe "BranchListView", ->
  beforeEach ->
    @view = new BranchListView(repo, "branch1\nbranch2")
    spyOn(git, 'cmd').andCallFake ->
      Promise.reject 'blah'

  it "displays a list of branches", ->
    expect(@view.items.length).toBe 2

  it "checkouts the selected branch", ->
    @view.confirmSelection()
    @view.checkout 'branch1'
    waitsFor -> git.cmd.callCount > 0
    runs ->
      expect(git.cmd).toHaveBeenCalledWith ['checkout', 'branch1'], cwd: repo.getWorkingDirectory()
