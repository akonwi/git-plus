git = require '../git'
ListView = require '../views/remote-list-view'

gitPush = ->
  git(
    ['remote'],
    (data) -> new ListView(data.toString(), 'push')
  )

module.exports = gitPush
