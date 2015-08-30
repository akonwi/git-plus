git = require '../../lib/git'
{repo} = require '../fixtures'
BranchListView = require '../../lib/views/branch-list-view'

describe "BranchListView", ->
  beforeEach ->
    spyOn(git, 'cmd').andCallFake ->
      Promise.reject 'blah'

  it "displays a list of branches", ->
    view = new BranchListView(repo, "branch1\nbranch2")
    expect(view.items.length).toBe 2

  it "checkouts the selected branch", ->
    view = new BranchListView(repo, "branch1\nbranch2")
    view.confirmSelection()
    expect(git.cmd).toHaveBeenCalledWith ['checkout', 'branch1'], cwd: repo.getWorkingDirectory()
