// @flow
import { GitRepository } from 'atom'
import { getRepo } from './git-es'
import git from './git'

export type Stash = {
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
    const r = await getRepo()
    return new Repository(r)
  }

  constructor(repo: GitRepository) {
    this.repo = repo
  }

  getStashes(): Promise<Stash[]> {
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

  actOnStash(reference: Stash, command: StashCommand): Promise<void> {
    const args = ['stash', command.name, reference.index]
    return git.cmd(args, { cwd: this.repo.getWorkingDirectory() })
  }
}
