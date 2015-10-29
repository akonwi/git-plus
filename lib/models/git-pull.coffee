git = require '../git'
RemoteListView = require '../views/remote-list-view'

module.exports = (repo, {rebase}={}) ->
  extraArgs = ['--rebase'] if rebase
  git.cmd(['remote'], cwd: repo.getWorkingDirectory())
  .then (data) -> new RemoteListView(repo, data, mode: 'pull', extraArgs: extraArgs).result
