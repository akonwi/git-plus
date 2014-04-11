{BufferedProcess} = require 'atom'
ListView = require './branch-list-view'

gitBranches = ->
  dir = atom.project.getRepo().getWorkingDirectory()
  new BufferedProcess({
    command: 'git'
    args: ['branch']
    options:
      cwd: dir
    stdout: (data) ->
      new ListView(data.toString())
    stderr: (data) ->
      alert data.toString()
  })

module.exports = gitBranches
