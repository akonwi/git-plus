git = require '../git'
ListView = require '../views/remote-list-view'

gitPush = ->
  git.cmd(
    args: ['remote'],
    stdout: (data) -> new ListView(data.toString(), 'push')
  )

module.exports = gitPush
