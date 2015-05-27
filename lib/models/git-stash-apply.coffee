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
      repo.destroy() if repo.destroyable
    stderr: (data) ->
      notifier.addError(data.toString())
      repo.destroy() if repo.destroyable

module.exports = gitStashApply
