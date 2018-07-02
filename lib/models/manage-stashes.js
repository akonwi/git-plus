// @flow
import SelectList from 'atom-select-list'
import Repository, { StashCommands } from '../repository'
import type { Stash, StashCommand } from '../repository'
import type { Panel } from '../types'

class StashListView {
  isAttached = false
  listView: SelectList<Stash>
  panel: Panel
  previouslyFocusedElement: ?HTMLElement

  constructor(stashes: Stash[], handleSelection: Stash => void) {
    this.listView = new SelectList({
      items: stashes,
      emptyMessage: 'Your stash is empty',
      filterKeyForItem: stash => stash.content,
      elementForItem: (stash, _options) => {
        const li = document.createElement('li')
        li.textContent = `${stash.index}: ${stash.label}`
        return li
      },
      didCancelSelection: () => {
        this.destroy()
        this.restoreFocus()
      },
      didConfirmSelection: stash => {
        handleSelection(stash)
        this.destroy()
      }
    })
    this.attach()
  }

  attach() {
    this.previouslyFocusedElement = document.activeElement
    this.panel = atom.workspace.addModalPanel({ item: this.listView.element })
    this.listView.focus()
    this.isAttached = true
  }

  destroy = () => {
    if (this.isAttached) {
      this.panel.destroy()
      this.listView.destroy()
    }
  }

  restoreFocus = () => {
    this.previouslyFocusedElement && this.previouslyFocusedElement.focus()
  }
}

type StashOptionItem = StashCommand & {
  label: string
}

class StashOptionsView {
  isAttached = false
  listView: SelectList<StashOptionItem>
  panel: Panel
  previouslyFocusedElement: ?HTMLElement

  constructor(stash: Stash, handleSelection: StashCommand => any) {
    this.listView = new SelectList({
      items: Object.entries(StashCommands).map(entry => ({ label: entry[0], ...entry[1] })),
      filterKeyForItem: command => command.label,
      elementForItem: (command, _options) => {
        const li = document.createElement('li')
        const labelDiv = document.createElement('div')
        labelDiv.classList.add('text-highlight')
        labelDiv.textContent = command.label
        const infoDiv = document.createElement('div')
        infoDiv.classList.add('text-info')
        infoDiv.textContent = stash.label
        li.append(labelDiv, infoDiv)
        return li
      },
      didCancelSelection: this.destroy,
      didConfirmSelection: (command: StashCommand) => {
        handleSelection(command)
        this.destroy()
      }
    })
    this.attach()
  }

  attach() {
    this.previouslyFocusedElement = document.activeElement
    this.panel = atom.workspace.addModalPanel({ item: this.listView.element })
    this.listView.focus()
    this.isAttached = true
  }

  focus() {
    if (this.isAttached) this.listView.focus()
  }

  destroy = () => {
    if (this.isAttached) {
      this.panel.destroy()
      this.previouslyFocusedElement && this.previouslyFocusedElement.focus()
      this.listView.destroy()
    }
  }
}

export default async () => {
  const repo = await Repository.getCurrent()
  const stashes = await repo.getStash()
  new StashListView(stashes, stash => {
    const optionsView = new StashOptionsView(stash, async command => {
      repo
        .actOnStash(stash, command)
        .then(() =>
          atom.notifications.addSuccess(
            `stash@{${stash.index}} ${command.pastTense} successfully`,
            {
              detail: stash.label
            }
          )
        )
        .catch(error =>
          atom.notifications.addError(
            `There was an error ${command.presentTense} stash@{${stash.index}}`,
            {
              detail: error
            }
          )
        )
    })
    optionsView.focus()
  })
}
