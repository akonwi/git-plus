git = require '../git'
StatusListView = require '../views/status-list-view'

module.exports = (repo) ->
  git.status(repo).then (data) -> new StatusListView(repo, data)
