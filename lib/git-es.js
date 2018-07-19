// @flow
import { BufferedProcess, Directory, GitRepository } from 'atom'
import chooseRepo from './models/choose-repo'

const getRepoForDirectory: Directory => Promise<
  GitRepository
> = atom.project.repositoryForDirectory.bind(atom.project)

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

  const repos: GitRepository[] = await Promise.all(
    atom.project.getDirectories().map(getRepoForDirectory)
  ).then(results => results.filter(Boolean))

  if (repos.length === 1) return repos[0]
  if (repos.length === 0) return null
  if (repos.length > 0) return chooseRepo(repos)
}

export const getRepoForPath = (path: string) => {
  const directory = new Directory(path)
  const repo = reposByDirectory.get(directory.getPath())
  if (repo) return repo
  else {
    let repo = getRepoForDirectory(directory)
    reposByDirectory.set(directory, repo)
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
