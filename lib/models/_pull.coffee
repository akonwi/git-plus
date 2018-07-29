git = require '../git'
notifier = require '../notifier'
ActivityLogger = require('../activity-logger').default

emptyOrUndefined = (thing) -> thing isnt '' and thing isnt undefined

getUpstream = (repo) ->
  branchInfo = repo.getUpstreamBranch()?.substring('refs/remotes/'.length).split('/')
  return null if not branchInfo
  remote = branchInfo[0]
  branch = branchInfo.slice(1).join('/')
  [remote, branch]

module.exports = (repo, {extraArgs}={}) ->
  if upstream = getUpstream(repo)
    if typeof extraArgs is 'string' then extraArgs = [extraArgs]
    extraArgs ?= []
    startMessage = notifier.addInfo "Pulling...", dismissable: true
    recordMessage ="""pull #{extraArgs.join(' ')}"""
    args = ['pull'].concat(extraArgs).concat(upstream).filter(emptyOrUndefined)
    git.cmd(args, cwd: repo.getWorkingDirectory(), {color: true})
    .then (output) ->
      ActivityLogger.record({message: recordMessage, output})
      startMessage.dismiss()
    .catch (output) ->
      ActivityLogger.record({message: recordMessage, output, failed: true})
      startMessage.dismiss()
  else
    notifier.addInfo 'The current branch is not tracking from upstream'
