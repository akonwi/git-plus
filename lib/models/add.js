// @flow
import Repository from '../repository'
import ActivityLogger from '../activity-logger'

const getCurrentFileInRepo = (repo: Repository) => {
  const activeEditor = atom.workspace.getActiveTextEditor()
  if (!activeEditor) return null
  return repo.relativize(activeEditor.getPath())
}

export default async () => {
  const repo = await Repository.getCurrent()
  const path = getCurrentFileInRepo(repo) || '.'
  const result = await repo.add(path)
  ActivityLogger.record({
    command: `git add ${path}`,
    result: result.output
  })
}
