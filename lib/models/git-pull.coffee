git = require '../git'
pull = require './_pull'
RemoteListView = require '../views/remote-list-view'

module.exports = (repo) ->
  extraArgs = if atom.config.get('git-plus.remoteInteractions.pullRebase') then ['--rebase'] else []
  if atom.config.get('git-plus.remoteInteractions.alwaysPullFromUpstream')
    pull repo, {extraArgs}
  else
    git.cmd(['remote'], cwd: repo.getWorkingDirectory())
    .then (data) -> new RemoteListView(repo, data, mode: 'pull', extraArgs: extraArgs).result
