// @flow
import Repository from '../repository'
import ActivityLogger from '../activity-logger'

const getCurrentFileInRepo = (repo: Repository) => {
  const activeEditor = atom.workspace.getActiveTextEditor()
  if (!activeEditor) return null
  return repo.relativize(activeEditor.getPath())
}

export default async (checkoutEverything: boolean = false) => {
  const repo = await Repository.getCurrent()
  const path = checkoutEverything ? '.' : getCurrentFileInRepo(repo) || '.'
  const result = await repo.resetChanges(path)
  ActivityLogger.record({
    repoName: repo.getName(),
    message: `reset changes in ${path}`,
    ...result
  })
}
