git = require '../git'
StatusView = require '../views/status-view'
Path = require 'path'

gitCheckoutCurrentFile = ->
  currentFile = atom.project.relativize atom.workspace.getActiveEditor()?.getPath()
  git.cmd
    args: ['checkout', '--', currentFile],
    stdout: (data) ->
      new StatusView(type: 'success', message: data.toString())
      atom.project.getRepo()?.refreshStatus()

module.exports = gitCheckoutCurrentFile
