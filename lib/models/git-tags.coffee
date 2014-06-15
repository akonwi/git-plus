git = require '../git'
TagListView = require '../views/tag-list-view'

gitTags = ->
  @TagListView = null
  git.cmd
    args: ['tag', '-ln'],
    stdout: (data) -> @TagListView = new TagListView(data),
    exit: -> new TagListView('') if not @TagListView?

module.exports = gitTags
