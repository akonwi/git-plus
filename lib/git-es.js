// @flow
import { BufferedProcess, Directory, File, GitRepository } from 'atom'
import chooseRepo from './models/choose-repo'

const getRepoForDirectory: Directory => Promise<
  GitRepository
> = atom.project.repositoryForDirectory.bind(atom.project)

const reposByDirectory: Map<Directory, GitRepository> = new Map()

const getCachedRepo = (path: string): ?GitRepository => {
  const iterator = reposByDirectory.entries()
  let entry = iterator.next()
  while (!entry.done) {
    const [directory, repo] = entry.value
    if (directory.contains(path)) return repo

    entry = iterator.next()
  }
}

const cacheRepo = (repo: GitRepository) =>
  reposByDirectory.set(new Directory(repo.getWorkingDirectory(), repo))

export async function getRepo(): Promise<GitRepository> {
  const activeEditor = atom.workspace.getCenter().getActiveTextEditor()
  if (activeEditor) {
    const path = activeEditor.getPath()
    let repo = getCachedRepo(path)
    if (repo) return repo

    const directory = new File(path).getParent()
    repo = await getRepoForDirectory(directory)
    if (repo) {
      cacheRepo(repo)
      return repo
    }
  }

  const repos: GitRepository[] = await Promise.all(
    atom.project.getDirectories().map(getRepoForDirectory)
  ).then(results => results.filter(Boolean))

  let repo

  if (repos.length === 0) return null
  if (repos.length === 1) repo = repos[0]
  if (repos.length > 0) repo = await chooseRepo(repos)

  cacheRepo(repo)
  return repo
}

export const getRepoForPath = async (path: string) => {
  const repo = getCachedRepo(path)
  if (repo) return repo
  else {
    let repo = await getRepoForDirectory(new File(path).getParent())
    cacheRepo(repo)
    return repo
  }
}

// getRepoForPath: (path) ->
//   if not path?
//     Promise.reject "No file to find repository for"
//   else
//     new Promise (resolve, reject) ->
//       repoPromises =
//         atom.project.getDirectories()
//         .map(atom.project.repositoryForDirectory.bind(atom.project))
//
//       Promise.all(repoPromises).then (repos) ->
//         repos.filter(Boolean).forEach (repo) ->
//           directory = new Directory(repo.getWorkingDirectory())
//           if repo? and directory.contains(path) or directory.getPath() is path
//             submodule = repo?.repo.submoduleForPath(path)
//             if submodule? then resolve(submodule) else resolve(repo)

const defaultCmdOptions = { color: false, env: process.env }

type GitCliOptions = {
  cwd?: string,
  color?: boolean,
  env?: {}
}
export type GitCliResponse = {
  output: string,
  failed: boolean
}

export default async function cmd(
  args: string[],
  options: GitCliOptions = defaultCmdOptions
): Promise<GitCliResponse> {
  if (options.color) {
    args = ['-c', 'color.ui=always'].concat(args)
    delete options.color
  }

  return new Promise((resolve, reject) => {
    let output = ''
    const gitProcess = new BufferedProcess({
      //$FlowFixMe
      command: atom.config.get('git-plus.general.gitPath') || 'git',
      args,
      options,
      stdout: data => (output += data.toString()),
      stderr: data => (output += data.toString()),
      exit: code => {
        resolve({
          output: output.trim(),
          failed: code !== 0
        })
      }
    })
    // TODO: clean up the disposable from this subscription
    gitProcess.onWillThrowError(_error => {
      atom.notifications.addError(
        'Git Plus is unable to locate the git command. Please ensure process.env.PATH can access git.'
      )
      reject(Error("Couldn't find git"))
    })
  })
}
