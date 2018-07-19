// @flow
import Repository from '../repository'
import type { PullOptions } from '../repository'
import ActivityLogger from '../activity-logger'
import ListView from '../views/list-view'

export default async () => {
  const repo = await Repository.getCurrent()

  if (repo.hasUpstream()) {
    const shouldRebase = atom.config.get('git-plus.remoteInteractions.pullRebase') === true
    const shouldAutostash = atom.config.get('git-plus.remoteInteractions.pullAutostash') === true
    const pullOptions: PullOptions = { rebase: shouldRebase, autostash: shouldAutostash }

    if (atom.config.get('git-plus.remoteInteractions.promptForBranch') === true) {
      const remotes = await repo.getRemoteNames()

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

      pullOptions.remote = chosenRemote
      pullOptions.branch = chosenBranch
    }

    const result = await repo.pull(pullOptions)
    ActivityLogger.record({
      message: `pull`,
      ...result
    })
  } else atom.notifications.addInfo('The current branch is not tracking from upstream')
}
