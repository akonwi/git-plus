git = require '../git'
TagListView = require '../views/tag-list-view'

module.exports = (repo) ->
  git.cmd(['tag', '-ln'], cwd: repo.getWorkingDirectory())
  .then (data) -> new TagListView(repo, data)
  .catch -> new TagListView(repo)
