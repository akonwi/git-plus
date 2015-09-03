git = require '../../lib/git'
{repo} = require '../fixtures'
StatusListView = require '../../lib/views/status-list-view'

describe "StatusListView", ->
  describe "when there are modified files", ->
    beforeEach ->
      @view = new StatusListView(repo, [" M\tfile.txt", " D\tanother.txt", ''])

    it "displays a list of modified files", ->
      expect(@view.items.length).toBe 2

  it "checkouts the selected branch", ->
    @view.confirmSelection()
    @view.checkout 'branch1'
    waitsFor -> git.cmd.callCount > 0
    expect(git.cmd).toHaveBeenCalledWith ['checkout', 'branch1'], cwd: repo.getWorkingDirectory()
