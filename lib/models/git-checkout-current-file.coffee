git = require '../git'
StatusView = require '../views/status-view'
Path = require 'path'

gitCheckoutCurrentFile = ->
  currentFile = atom.project.getRepo().relativize atom.workspace.getActiveEditor()?.getPath()
  git(
    ['checkout', currentFile],
    (data) -> new StatusView(type: 'success', message: data.toString())
  )

module.exports = gitCheckoutCurrentFile
