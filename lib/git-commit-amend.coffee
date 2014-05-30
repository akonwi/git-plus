{BufferedProcess} = require 'atom'
StatusView = require './status-view'
gitCommit = require './git-commit'
Os = require 'os'
Path = require 'path'
fs = require 'fs'


gitMsg = () ->
  dir = atom.project.getRepo().getWorkingDirectory()
  currentFile = atom.workspace.getActiveEditor()?.getPath()
  new BufferedProcess({
    command: 'git'
    args: ['log', '-1', '--format=%s']
    options:
      cwd: dir
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
    stdout: (data) ->
      gitCommit "- " + data.toString()
  })

  
module.exports = gitMsg
