{repo} = require '../fixtures'
BranchListView = require '../../lib/views/branch-list-view'

describe "BranchListView", ->
  it "displays a list of branches", ->
    view = new BranchListView(repo, "branch1\nbranch2")
    expect(view.items.length).toBe 2

  describe "when an item is selected", ->
    it "runs the provided function with the selected item", ->
      onConfirm = jasmine.createSpy()
      view = new BranchListView(repo, "branch1\nbranch2", onConfirm)
      view.confirmSelection()
      expect(onConfirm).toHaveBeenCalledWith name: 'branch1'

    it "removes the '*' character from in the branch name if it is there", ->
      onConfirm = jasmine.createSpy()
      view = new BranchListView(repo, "*branch1\nbranch2", onConfirm)
      view.confirmSelection()
      expect(onConfirm).toHaveBeenCalledWith name: 'branch1'
