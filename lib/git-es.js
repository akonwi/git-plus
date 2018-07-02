// @flow
import { Directory, GitRepository } from 'atom'
import chooseRepo from './models/choose-repo'

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

  const getRepoForDirectory: Directory => Promise<
    GitRepository
  > = atom.project.repositoryForDirectory.bind(atom.project)
  const repos: GitRepository[] = await Promise.all(
    atom.project.getDirectories().map(getRepoForDirectory)
  ).then(results => results.filter(Boolean))

  if (repos.length === 1) return repos[0]
  if (repos.length === 0) return null
  if (repos.length > 0) return chooseRepo(repos)
}
