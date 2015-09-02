git = require '../../lib/git'
{repo} = require '../fixtures'
RemoveListView = require '../../lib/views/remove-list-view'

describe "RemoveListView", ->
  it "displays a list of files", ->
    view = new RemoveListView(repo, ['file1', 'file2'])
    expect(view.items.length).toBe 2
