git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'

emptyOrUndefined = (thing) -> thing isnt '' and thing isnt undefined

getUpstream = (repo) ->
  repo.getUpstreamBranch()?.substring('refs/remotes/'.length).split('/')

module.exports = (repo, {extraArgs}={}) ->
  extraArgs ?= []
  view = OutputViewManager.create()
  startMessage = notifier.addInfo "Pulling...", dismissable: true
  args = ['pull'].concat(extraArgs).concat(getUpstream(repo)).filter(emptyOrUndefined)
  git.cmd(args, cwd: repo.getWorkingDirectory(), {color: true})
  .then (data) ->
    view.setContent(data).finish()
    startMessage.dismiss()
  .catch (error) ->
    view.setContent(error).finish()
    startMessage.dismiss()
