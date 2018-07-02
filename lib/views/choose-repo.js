// @flow
import typeof { GitRepository } from 'atom'
import type { Panel } from '../types'
import SelectList from 'atom-select-list'

type RepoItem = {
  repo: GitRepository,
  name: string
}

class RepoListView {
  isAttached = false
  list: SelectList<RepoItem>
  previouslyFocusedElement: ?HTMLElement
  panel: Panel
  result: Promise<GitRepository>

  constructor(repos: GitRepository[]) {
    this.result = new Promise((resolve, reject) => {
      this.list = new SelectList({
        items: repos.map(repository => {
          const path = repository.getWorkingDirectory()
          return {
            repo: repository,
            name: path.substring(path.lastIndexOf('/') + 1)
          }
        }),
        filterKeyForItem(item) {
          return item.name
        },
        infoMessage: 'Which Repo?',
        elementForItem(item, _options) {
          const li = document.createElement('li')
          li.textContent = item.name
          return li
        },
        didCancelSelection: () => {
          this.destroy()
          reject('User aborted')
        },
        didConfirmSelection: item => {
          resolve(item.repo)
          this.destroy()
        }
      })
    })
    this.attach()
  }

  attach() {
    this.previouslyFocusedElement = document.activeElement
    this.panel = atom.workspace.addModalPanel({ item: this.list.element })
    this.list.focus()
    this.isAttached = true
  }

  destroy = () => {
    if (this.isAttached) {
      this.panel.destroy()
      this.previouslyFocusedElement && this.previouslyFocusedElement.focus()
      this.list.destroy()
    }
  }
}

export default async (repos: GitRepository[]): Promise<GitRepository> => {
  return new RepoListView(repos).result
}
