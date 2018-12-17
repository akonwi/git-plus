git = require '../../lib/git'
{repo} = require '../fixtures'
TagListView = require '../../lib/views/tag-list-view'

describe "TagListView", ->
  describe "when there are two tags", ->
    it "displays a list of tags", ->
      view = new TagListView(repo, "tag1\ntag2")
      expect(view.items.length).toBe 2

  describe "when there are no tags", ->
    it "displays a message to 'Add Tag'", ->
      view = new TagListView(repo)
      expect(view.items.length).toBe 1
      expect(view.items[0].tag).toBe '+ Add Tag'
