// @flow
import { GitRepository } from 'atom'
import git from './git'

export type StashReference = {
  index: string,
  label: string,
  content: string
}

export type StashCommand = {
  name: string,
  pastTense: string,
  presentTense: string
}

export const StashCommands: { [label: string]: StashCommand } = {
  Apply: { name: 'apply', pastTense: 'applied', presentTense: 'applying' },
  Pop: { name: 'pop', pastTense: 'popped', presentTense: 'popping' },
  Drop: { name: 'drop', pastTense: 'dropped', presentTense: 'dropping' }
}

export default class Repository {
  repo: GitRepository

  static async getCurrent(): Promise<Repository> {
    const r = await git.getRepo()
    return new Repository(r)
  }

  constructor(repo: GitRepository) {
    this.repo = repo
  }

  getStash(): Promise<StashReference[]> {
    return git.cmd(['stash', 'list'], { cwd: this.repo.getWorkingDirectory() }).then(data => {
      return data
        .split('\n')
        .filter(Boolean)
        .map(stashInfo => {
          const [indexInfo, ...rest] = stashInfo.split(':')
          const indexMatch = indexInfo.match(/\d+/)
          if (!indexMatch) return null
          return { index: indexMatch[0], label: rest.join().trim(), content: stashInfo }
        })
        .filter(Boolean)
    })
  }

  stash(reference: StashReference, command: StashCommand) {
    const args = ['stash', command.name, reference.index]
    return git.cmd(args, { cwd: this.repo.getWorkingDirectory() })
  }
}
