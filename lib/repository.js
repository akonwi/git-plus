// @flow
import { GitRepository } from 'atom'
import git, { getRepo } from './git-es'
import type { GitCliResponse } from './git-es'

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
    const repo = await getRepo()
    return new Repository(repo)
  }

  constructor(repo: GitRepository) {
    this.repo = repo
  }

  add(path: string): Promise<GitCliResponse> {
    return git(['add', '--all', path], { cwd: this.repo.getWorkingDirectory() })
  }

  getStashes(): Promise<Stash[]> {
    return git(['stash', 'list'], { cwd: this.repo.getWorkingDirectory() }).then(response => {
      if (response.success)
        return response.output
          .split('\n')
          .filter(Boolean)
          .map(stashInfo => {
            const [indexInfo, ...rest] = stashInfo.split(':')
            const indexMatch = indexInfo.match(/\d+/)
            if (!indexMatch) return null
            return { index: indexMatch[0], label: rest.join().trim(), content: stashInfo }
          })
          .filter(Boolean)
      else return []
    })
  }

  actOnStash(stash: Stash, command: StashCommand): Promise<GitCliResponse> {
    const args = ['stash', command.name, stash.index]
    return git(args, { cwd: this.repo.getWorkingDirectory() })
  }

  relativize(path: string): string | void {
    return this.repo.relativize(path)
  }
}