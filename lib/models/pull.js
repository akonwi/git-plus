// @flow
import Repository from '../repository'
import ActivityLogger from '../activity-logger'

export default async () => {
  const repo = await Repository.getCurrent()
  if (repo.hasUpstream()) {
    const shouldRebase = atom.config.get('git-plus.remoteInteractions.pullRebase') === true
    const result = await repo.pull({ rebase: shouldRebase })
    ActivityLogger.record({
      message: `pull ${shouldRebase ? '--rebase' : ''}`,
      ...result
    })
  } else atom.notifications.addInfo('The current branch is not tracking from upstream')
}
