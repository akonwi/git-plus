git = require '../git'
ListView = require '../views/remote-list-view'
StatusView = require '../views/status-view'

dir = ->
  atom.project.getRepo().getWorkingDirectory()

gitPush = ->
  git(
    ['remote'],
    (data) -> new ListView(data.toString(), 'push')
  )

module.exports = gitPush
