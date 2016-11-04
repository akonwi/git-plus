git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'

module.exports = (repo) ->
  cwd = repo.getWorkingDirectory()
  git.cmd(['stash', 'drop'], {cwd}, color: true)
  .then (msg) ->
    OutputViewManager.create().setContent(msg).finish() if msg isnt ''
  .catch (msg) ->
    notifier.addInfo msg
