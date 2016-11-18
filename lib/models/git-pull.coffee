git = require '../git'
pull = require './_pull'
RemoteListView = require '../views/remote-list-view'

experimentalFeaturesEnabled = () ->
  gitPlus = atom.config.get('git-plus')
  gitPlus.alwaysPullFromUpstream and gitPlus.experimental

module.exports = (repo, {rebase}={}) ->
  extraArgs = if rebase then ['--rebase'] else []
  if experimentalFeaturesEnabled()
    pull repo, {extraArgs}
  else
    git.cmd(['remote'], cwd: repo.getWorkingDirectory())
    .then (data) -> new RemoteListView(repo, data, mode: 'pull', extraArgs: extraArgs).result
