git = require '../git'
notifier = require '../notifier'

gitStashApply = (repo) ->
  git.cmd
    args: ['stash', 'apply']
    cwd: repo.getWorkingDirectory()
    options: {
      env: process.env.NODE_ENV
    }
    stdout: (data) ->
      notifier.addSuccess(data) if data.toString().length > 0
    stderr: (data) ->
      notifier.addError(data.toString())

module.exports = gitStashApply
