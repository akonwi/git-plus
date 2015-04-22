git = require '../git'
TagListView = require '../views/tag-list-view'

gitTags = (repo) ->
  @TagListView = null
  git.cmd
    args: ['tag', '-ln']
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> @TagListView = new TagListView(repo, data),
    exit: -> new TagListView(repo) if not @TagListView?

module.exports = gitTags
