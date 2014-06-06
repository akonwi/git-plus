{BufferedProcess} = require 'atom'
ListView = require '../views/remote-list-view'
StatusView = require '../views/status-view'

dir = ->
  atom.project.getRepo().getWorkingDirectory()

gitFetch = ->
  # first get the remote repos
  new BufferedProcess(
    command: 'git'
    args: ['remote']
    options:
      cwd: dir()
    stdout: (data) ->
      new ListView(data.toString(), 'fetch')
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
  )

module.exports = gitFetch
