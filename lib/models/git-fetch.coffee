git = require '../git'
ListView = require '../views/remote-list-view'

gitFetch = ->
  git(
    ['remote'],
    (data) -> new ListView(data.toString(), 'fetch')
  )

module.exports = gitFetch
