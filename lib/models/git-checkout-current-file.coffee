git = require '../git'
notifier = require '../notifier'

gitCheckoutCurrentFile = (repo)->
  currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  git.cmd
    args: ['checkout', '--', currentFile]
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> # There is no output from this command
      notifier.addSuccess 'File changes checked out successfully'
      git.refresh()

module.exports = gitCheckoutCurrentFile
