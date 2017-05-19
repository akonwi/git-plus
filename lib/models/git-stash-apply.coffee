git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'

module.exports = (repo) ->
  cwd = repo.getWorkingDirectory()
  git.cmd(['stash', 'apply'], {cwd}, color: true)
  .then (msg) ->
    OutputViewManager.getView().showContent(msg) if msg isnt ''
  .catch (msg) ->
    notifier.addInfo msg
