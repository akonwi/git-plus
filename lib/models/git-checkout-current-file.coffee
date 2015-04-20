git = require '../git'
StatusView = require '../views/status-view'

gitCheckoutCurrentFile = (repo)->
  currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  git.cmd
    args: ['checkout', '--', currentFile]
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> # There is no output from this command
      new StatusView(type: 'success', message: 'File changes checked out successfully')
      git.refresh repo
      repo.destroy() if repo.destroyable

module.exports = gitCheckoutCurrentFile
