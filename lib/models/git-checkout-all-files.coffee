git = require '../git'
notifier = require '../notifier'

gitCheckoutAllFiles = (repo) ->
  git.cmd
    args: ['checkout', '-f']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      notifier.addSuccess "File changes checked out successfully!"
      git.refresh()

module.exports = gitCheckoutAllFiles
