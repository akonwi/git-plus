git = require '../git'
notifier = require '../notifier'

module.exports = (repo) ->
  cwd = repo.getWorkingDirectory()
  git.cmd(['stash', 'save'], {cwd})
  .then (data) ->
    notifier.addSuccess data
  .catch (msg) ->
    notifier.addInfo msg
