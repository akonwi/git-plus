// @flow
import Repository from '../repository'
import ActivityLogger from '../activity-logger'

export default async () => {
  const repo = await Repository.getCurrent()
  const result = await repo.reset()
  ActivityLogger.record({
    repoName: repo.getName(),
    message: 'reset index',
    ...result
  })
}
