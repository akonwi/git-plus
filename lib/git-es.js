// @flow
import { Directory } from 'atom'

const reposByDirectory: Map<string, GitRepository> = new Map()

export async function getRepo(): Promise<GitRepository> {
  const activeEditor = atom.workspace.getCenter().getActiveTextEditor()
  if (activeEditor) {
    const path = activeEditor.getPath()
    const directory = new Directory(path)
    let repo = reposByDirectory.get(directory.getPath())
    if (repo) return repo

    repo = await atom.project.repositoryForDirectory(directory)
    if (repo) {
      reposByDirectory.set(directory.getPath(), repo)
      return repo
    }
  }
  // TODO: try another ways
}
