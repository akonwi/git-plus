git = require '../git'
RemoteListView = require '../views/remote-list-view'

gitPush = ->
  git.cmd
    args: ['remote'],
    stdout: (data) -> new RemoteListView(data, 'push')

module.exports = gitPush
