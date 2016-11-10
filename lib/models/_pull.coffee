git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'

module.exports = (repo, {remote, branch, extraArgs}) ->
  new Promise (resolve, reject) ->
    view = OutputViewManager.create()
    startMessage = notifier.addInfo "Pulling...", dismissable: true
    args = ['pull'].concat(extraArgs).concat([remote, branch]).filter (c) -> c isnt '' and c isnt undefined
    git.cmd(args, cwd: repo.getWorkingDirectory(), {color: true})
    .then (data) =>
      resolve()
      view.setContent(data).finish()
      startMessage.dismiss()
    .catch (error) =>
      reject()
      view.setContent(error).finish()
      startMessage.dismiss()
