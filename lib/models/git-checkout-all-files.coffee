git = require '../git'
notifier = require '../notifier'

module.exports = (repo) ->
  git.cmd(['checkout', '-f'], cwd: repo.getWorkingDirectory())
  .then (data) ->
    notifier.addSuccess "File changes checked out successfully!"
    git.refresh()
