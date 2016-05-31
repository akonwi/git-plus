git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'

module.exports = (repo, {message}={}) ->
  cwd = repo.getWorkingDirectory()
  args = ['stash', 'save']
  args.push(message) if message
  git.cmd(args, {cwd})
  .then (msg) ->
    OutputViewManager.create().addLine(msg).finish() if msg isnt ''
  .catch (msg) ->
    notifier.addInfo msg
