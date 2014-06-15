git = require '../git'
ListView = require '../views/remote-list-view'

gitFetch = ->
  git.cmd
    args: ['remote'],
    stdout: (data) -> new ListView(data.toString(), 'fetch')

module.exports = gitFetch
