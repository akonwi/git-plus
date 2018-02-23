RemoteBranchListView = require '../../lib/views/remote-branch-list-view'

describe "RemoteBranchListView", ->
  onConfirm = jasmine.createSpy()
  view = new RemoteBranchListView("remote/branch1\nremote/branch2\norigin/branch3", "remote", onConfirm)

  it "only shows branches from the selected remote", ->
    expect(view.items.length).toBe 2

  describe "when an item is selected", ->
    it "calls the provided callback with the selected item", ->
      view.confirmSelection()
      expect(onConfirm).toHaveBeenCalledWith name: 'remote/branch1'
