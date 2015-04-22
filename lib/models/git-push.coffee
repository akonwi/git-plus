git = require '../git'
RemoteListView = require '../views/remote-list-view'

gitPush = (repo) ->
  git.cmd
    args: ['remote']
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> new RemoteListView(repo, data, mode: 'push')

module.exports = gitPush
