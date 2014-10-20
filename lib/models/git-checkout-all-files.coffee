git = require '../git'
StatusView = require '../views/status-view'

gitCheckoutAllFiles = ->
  git.cmd
    args: ['checkout', '-f'],
    stdout: (data) ->
      new StatusView(type: 'success', message: data.toString())
      atom.project.getRepo()?.refreshStatus()

module.exports = gitCheckoutAllFiles
