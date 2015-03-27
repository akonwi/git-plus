git = require '../git'
StatusView = require '../views/status-view'

gitCheckoutCurrentFile = ->
  currentFile = git.relativize(atom.workspace.getActiveEditor()?.getPath())
  git.cmd
    args: ['checkout', '--', currentFile],
    stdout: (data) ->
      new StatusView(type: 'success', message: data.toString())
      git.getRepo()?.refreshStatus?()

module.exports = gitCheckoutCurrentFile
