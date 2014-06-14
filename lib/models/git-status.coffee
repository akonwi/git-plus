git = require '../git'
StatusListView = require '../views/status-list-view'

gitStatus = ->
  git.status (data) -> new StatusListView(data)

module.exports = gitStatus
