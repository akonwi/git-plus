git = require '../git'
notifier = require '../notifier'

module.exports = (repo) ->
  notification = notifier.addInfo('Saving...', dismissable: true)
  options =
    cwd: repo.getWorkingDirectory()
    env: process.env.NODE_ENV
  git.cmd(['stash', 'save'], options)
  .then (data) ->
    notification.dismiss()
    notifier.addSuccess(data)
  .catch (msg) ->
    notifier.addError msg
