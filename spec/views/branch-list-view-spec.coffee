{repo} = require '../fixtures'
BranchListView = require '../../lib/views/branch-list-view'

describe "BranchListView", ->
  onConfirm = jasmine.createSpy()
  view = new BranchListView("*branch1\nbranch2", onConfirm)

  it "displays a list of branches", ->
    expect(view.items.length).toBe 2

  describe "when an item is selected", ->
    it "runs the provided function with the selected item", ->
      view.confirmSelection()
      expect(onConfirm).toHaveBeenCalledWith name: 'branch1'
