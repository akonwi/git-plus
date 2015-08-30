git = require '../git'
RemoteListView = require '../views/remote-list-view'

module.exports = (repo) ->
  git.cmd(['remote'], cwd: repo.getWorkingDirectory())
  .then (data) -> new RemoteListView(repo, data, mode: 'fetch-prune')
