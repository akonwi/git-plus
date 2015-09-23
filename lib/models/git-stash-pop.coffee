git = require '../git'
notifier = require '../notifier'

module.exports = (repo) ->
  cwd = repo.getWorkingDirectory()
  git.cmd(['stash', 'pop'], {cwd})
  .then (data) ->
    notifier.addSuccess(data) if data.toString().length > 0
  .catch (msg) ->
    notifier.addInfo msg
