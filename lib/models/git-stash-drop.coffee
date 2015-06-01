git = require '../git'
notifier = require '../notifier'

gitStashDrop = (repo) ->
  git.cmd
    args: ['stash', 'drop']
    cwd: repo.getWorkingDirectory()
    options: {
      env: process.env.NODE_ENV
    }
    stdout: (data) ->
      notifier.addSuccess(data) if data.toString().length > 0
    stderr: (data) ->
      notifier.addError(data)

module.exports = gitStashDrop
