import contextPackageFinder from '../../context-package-finder'
import Repository from '../../repository'
import ActivityLogger from '../../activity-logger'

export default async () => {
  const path = contextPackageFinder.get().selectedPath
  const repo = await Repository.getForPath(path)
  const result = await repo.add(path)
  ActivityLogger.record({
    message: `add ${repo.relativize(path)}`,
    ...result
  })
}
