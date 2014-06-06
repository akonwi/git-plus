git = require '../git'
TagListView = require '../views/tag-list-view'
StatusView = require '../views/status-view'

gitTags = ->
  @TagListView = null
  git(
    ['tag', '-ln'],
    (data) -> @TagListView = new TagListView(data),
    (exit) -> new TagListView('') if not @TagListView?
  )

module.exports = gitTags
