git = require '../git'
notifier = require '../notifier'

module.exports = (repo) ->
  cwd = repo.getWorkingDirectory()
  git.cmd(['stash', 'apply'], {cwd})
  .then (data) ->
    notifier.addSuccess(data) if data.length > 0
  .catch (msg) ->
    notifier.addInfo msg
