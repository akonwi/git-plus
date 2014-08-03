git = require '../git'
RemoteListView = require '../views/remote-list-view'

gitPull = ->
  git.cmd
    args: ['remote']
    stdout: (data) -> new RemoteListView(data, 'pull')

module.exports = gitPull
