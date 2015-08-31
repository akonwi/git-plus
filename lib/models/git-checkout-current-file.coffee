git = require '../git'
notifier = require '../notifier'

module.exports = (repo) ->
  currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  git.cmd(['checkout', '--', currentFile], cwd: repo.getWorkingDirectory())
  .then (data) ->
    notifier.addSuccess 'File changes checked out successfully'
    git.refresh()
