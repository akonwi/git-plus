git = require '../git'
notifier = require '../notifier'


module.exports = (repo) ->
  options =
    cwd: repo.getWorkingDirectory()
    env: process.env.NODE_ENV

  git.cmd(['stash', 'pop'], options)
  .then (data) ->
    notifier.addSuccess(data) if data.toString().length > 0
  .catch (data) ->
    notifier.addError(data)
