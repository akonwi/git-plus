// @flow
import Repository from '../repository'
import ActivityLogger from '../activity-logger'

const getCurrentFileInRepo = (repo: Repository) => {
  const activeEditor = atom.workspace.getActiveTextEditor()
  if (!activeEditor) return null
  return repo.relativize(activeEditor.getPath())
}

export default async (stageEverything: boolean = false) => {
  const repo = await Repository.getCurrent()
  const path = stageEverything ? '.' : getCurrentFileInRepo(repo) || '.'
  const result = await repo.add(path)
  ActivityLogger.record({
    repoName: repo.getName(),
    message: `add ${path}`,
    ...result
  })
}
