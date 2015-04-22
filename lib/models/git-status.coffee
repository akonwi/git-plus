git = require '../git'
StatusListView = require '../views/status-list-view'

gitStatus = (repo) ->
  git.status repo, (data) -> new StatusListView(repo, data)

module.exports = gitStatus
