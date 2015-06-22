git = require '../git'
RemoteListView = require '../views/remote-list-view'

gitPull = (repo, {rebase}={}) ->
  extraArgs = ['--rebase'] if rebase

  git.cmd
    args: ['remote']
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> new RemoteListView(repo, data, mode: 'pull', extraArgs: extraArgs)

module.exports = gitPull
