git = require '../git'
TagListView = require '../views/tag-list-view'

gitTags = ->
  @TagListView = null
  git(
    ['tag', '-ln'],
    (data) -> @TagListView = new TagListView(data),
    (exit) -> new TagListView('') if not @TagListView?
  )

module.exports = gitTags
