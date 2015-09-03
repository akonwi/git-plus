git = require '../git'
notifier = require '../notifier'

module.exports = (repo) ->
  options =
    cwd: repo.getWorkingDirectory()
    env: process.env.NODE_ENV
  git.cmd(['stash', 'apply'], options)
  .then (data) ->
    notifier.addSuccess(data) if data.length > 0
  .catch (data) ->
      notifier.addError(data)
