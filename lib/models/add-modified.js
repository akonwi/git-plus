// @flow
import Repository from '../repository'
import ActivityLogger from '../activity-logger'

export default async () => {
  const repo = await Repository.getCurrent()
  const result = await repo.add('.', { update: true })
  ActivityLogger.record({
    message: `add modified files`,
    ...result
  })
}
