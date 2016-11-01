git = require '../git'
RemoteListView = require '../views/remote-list-view'

module.exports = (repo, {setUpstream}={}) ->
  git.cmd(['remote'], cwd: repo.getWorkingDirectory()).then (data) ->
    mode = if setUpstream then 'push -u' else 'push'
    new RemoteListView(repo, data, {mode})
