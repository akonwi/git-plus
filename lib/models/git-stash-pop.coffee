git = require '../git'
StatusView = require '../views/status-view'

gitStashPop = (repo) ->
  git.cmd
    args: ['stash', 'pop']
    cwd: repo.getWorkingDirectory()
    options: {
      env: process.env.NODE_ENV
    }
    stdout: (data) ->
      new StatusView(type: 'success', message: data)
      repo.destroy() if repo.destroyable

module.exports = gitStashPop
