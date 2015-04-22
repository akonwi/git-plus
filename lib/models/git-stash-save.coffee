git = require '../git'
StatusView = require '../views/status-view'

gitStashSave = (repo) ->
  git.cmd
    args: ['stash', 'save']
    cwd: repo.getWorkingDirectory()
    options: {
      env: process.env.NODE_ENV
    }
    stdout: (data) ->
      new StatusView(type: 'success', message: data)
      repo.destroy() if repo.destroyable

module.exports = gitStashSave
