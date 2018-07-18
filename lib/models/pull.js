// @flow
import Repository from '../repository'
import ActivityLogger from '../activity-logger'

export default async () => {
  const repo = await Repository.getCurrent()
  if (repo.hasUpstream()) {
    const shouldRebase = atom.config.get('git-plus.remoteInteractions.pullRebase') === true
    const shouldAutostash = atom.config.get('git-plus.remoteInteractions.pullAutostash') === true
    const result = await repo.pull({ rebase: shouldRebase, autostash: shouldAutostash })
    ActivityLogger.record({
      message: `pull`,
      ...result
    })
  } else atom.notifications.addInfo('The current branch is not tracking from upstream')
}
