git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'

emptyOrUndefined = (thing) -> thing isnt '' and thing isnt undefined

getUpstream = (repo) ->
  branchInfo = repo.getUpstreamBranch()?.substring('refs/remotes/'.length).split('/')
  return null if not branchInfo
  remote = branchInfo[0]
  branch = branchInfo.slice(1).join('/')
  [remote, branch]

module.exports = (repo, {extraArgs}={}) ->
  if upstream = getUpstream(repo)
    extraArgs ?= []
    view = OutputViewManager.create()
    startMessage = notifier.addInfo "Pulling...", dismissable: true
    args = ['pull'].concat(extraArgs).concat(upstream).filter(emptyOrUndefined)
    git.cmd(args, cwd: repo.getWorkingDirectory(), {color: true})
    .then (data) ->
      view.setContent(data).finish()
      startMessage.dismiss()
    .catch (error) ->
      view.setContent(error).finish()
      startMessage.dismiss()
  else
    notifier.addInfo 'The current branch is not tracking from upstream'
