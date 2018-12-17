git = require '../../lib/git'
{repo} = require '../fixtures'
RebaseListView = require '../../lib/views/rebase-list-view'

describe "RebaseListView", ->
  beforeEach ->
    @view = new RebaseListView(repo, "branch1\nbranch2")
    spyOn(git, 'cmd').andCallFake ->
      Promise.reject 'blah'

  it "displays a list of branches", ->
    expect(@view.items.length).toBe 2

  it "rebases onto the selected branch", ->
    @view.confirmSelection()
    @view.rebase 'branch1'
    expect(git.cmd).toHaveBeenCalledWith ['rebase', 'branch1'], cwd: repo.getWorkingDirectory()
