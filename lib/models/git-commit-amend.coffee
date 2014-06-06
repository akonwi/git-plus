Os = require 'os'
Path = require 'path'
fs = require 'fs'

{BufferedProcess} = require 'atom'

StatusView = require '../views/status-view'
gitCommit = require './git-commit'

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
