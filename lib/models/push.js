// @flow
import Repository from '../repository'
import ActivityLogger from '../activity-logger'
import ListView from '../views/list-view'

export default async () => {
  const repo = await Repository.getCurrent()
  const pushOptions = {}

  const remotes = await repo.getRemoteNames()
  if (remotes.length === 0)
    atom.notifications.addInfo('There is no remote repository to push from.')
  else {
    if (atom.config.get('git-plus.remoteInteractions.promptForBranch')) {
      let chosenRemote
      if (remotes.length === 1) chosenRemote = remotes[0]
      else chosenRemote = await new ListView(remotes).result

      let chosenBranch
      const branches = await repo.getBranchesForRemote(chosenRemote)
      if (branches.length === 1) chosenBranch = branches[0]
      else
        chosenBranch = await new ListView(branches, {
          infoMessage: `Select branch on ${chosenRemote}`
        }).result
      pushOptions.remote = chosenRemote
      pushOptions.branch = chosenBranch
    }

    if (atom.config.get('git-plus.remoteInteractions.pullBeforePush')) {
      const result = await repo.pull({
        rebase: atom.config.get('git-plus.remoteInteractions.pullRebase') === true,
        autostash: atom.config.get('git-plus.remoteInteractions.pullAutostash') === true,
        remote: pushOptions.chosenRemote,
        branch: pushOptions.chosenBranch
      })
      ActivityLogger.record({
        message: 'pull before push',
        ...result
      })
      if (result.failed) return
    }

    const result = await repo.push(pushOptions)
    ActivityLogger.record({
      message: `push`,
      ...result
    })
  }
}
