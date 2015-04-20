git = require '../git'
StatusView = require '../views/status-view'

gitCheckoutAllFiles = (repo) ->
  git.cmd
    args: ['checkout', '-f']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      new StatusView(type: 'success', message: data.toString())
      git.refresh repo

module.exports = gitCheckoutAllFiles
