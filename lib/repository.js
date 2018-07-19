// @flow
import * as path from 'path'
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

export type AddOptions = {
  update?: boolean
}

export type FetchOptions = {
  prune?: boolean
}

export type PullOptions = {
  rebase?: boolean,
  autostash?: boolean,
  remote?: string,
  branch?: string
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

  add(path: string, options: AddOptions = { update: false }): Promise<GitCliResponse> {
    const args = ['add']
    if (options.update) args.push('--update')
    else args.push('--all')
    args.push(path)

    return git(args, { cwd: this.repo.getWorkingDirectory() })
  }

  getName() {
    return path.basename(this.repo.getWorkingDirectory())
  }

  getBranchesForRemote(remote: string): Promise<string[]> {
    return git(['branch', '-r', '--no-color'], { cwd: this.repo.getWorkingDirectory() }).then(
      response => {
        if (!response.failed) {
          const branches = []
          response.output.split('\n').forEach(ref => {
            ref = ref.trim()
            if (ref.startsWith(`${remote}/`) && !ref.includes('/HEAD')) {
              branches.push(ref.substring(ref.indexOf('/') + 1))
            }
          })
          return branches
        } else return []
      }
    )
  }

  getRemoteNames(): Promise<string[]> {
    return git(['remote'], { cwd: this.repo.getWorkingDirectory() }).then(response => {
      if (!response.failed) return response.output.split('\n').filter(Boolean)
      else return []
    })
  }

  getStashes(): Promise<Stash[]> {
    return git(['stash', 'list'], { cwd: this.repo.getWorkingDirectory() }).then(response => {
      if (!response.failed)
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

  fetch(remote?: string, options: FetchOptions = {}): Promise<GitCliResponse> {
    const args = ['fetch', remote || '--all']
    if (options.prune) args.push('--prune')
    return git(args, { cwd: this.repo.getWorkingDirectory(), color: true })
  }

  hasUpstream() {
    return Boolean(this.repo.getUpstreamBranch())
  }

  pull(options: PullOptions = {}) {
    const args = ['pull']
    if (options.autostash) args.push('--autostash')
    if (options.rebase) args.push('--rebase')
    if (options.remote) args.push(options.remote)
    if (options.branch) args.push(options.branch)

    return git(args, { cwd: this.repo.getWorkingDirectory() })
  }

  refresh() {
    this.repo.refreshIndex()
    this.repo.refreshStatus()
  }

  relativize(path: string): string | void {
    return this.repo.relativize(path)
  }

  async resetChanges(path: string): Promise<GitCliResponse> {
    const result = await git(['checkout', '--', path], { cwd: this.repo.getWorkingDirectory() })
    this.refresh()
    return result
  }
}
