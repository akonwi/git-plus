// @flow
import SelectList from 'atom-select-list'
import Repository, { StashCommands } from '../repository'
import type { StashReference, StashCommand } from '../repository'

type ISelectList = { destroy: Function, element: HTMLElement, focus: Function }

class StashListView {
  isAttached = false
  listView: ISelectList
  panel: Panel
  previouslyFocusedElement: ?HTMLElement

  constructor(references: StashReference[], handleSelection: StashReference => void) {
    this.listView = new SelectList({
      items: references,
      emptyMessage: 'Your stash is empty',
      filterKeyForItem: reference => reference.content,
      elementForItem: (reference, options) => {
        const li = document.createElement('li')
        li.textContent = `${reference.index}: ${reference.label}`
        return li
      },
      didCancelSelection: () => {
        this.destroy()
        this.restoreFocus()
      },
      didConfirmSelection: reference => {
        handleSelection(reference)
        this.destroy()
      }
    })
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

class StashOptionsView {
  isAttached = false
  listView: ISelectList
  panel: Panel
  previouslyFocusedElement: ?HTMLElement

  constructor(reference: StashReference, handleSelection: StashCommand => any) {
    this.listView = new SelectList({
      items: Object.entries(StashCommands).map(entry => ({ label: entry[0], ...entry[1] })),
      filterKeyForItem: command => command.label,
      elementForItem: (command, options) => {
        const li = document.createElement('li')
        const labelDiv = document.createElement('div')
        labelDiv.classList.add('text-highlight')
        labelDiv.textContent = command.label
        const infoDiv = document.createElement('div')
        infoDiv.classList.add('text-info')
        infoDiv.textContent = reference.label
        li.append(labelDiv, infoDiv)
        return li
      },
      didCancelSelection: this.destroy,
      didConfirmSelection: (command: StashCommand) => {
        handleSelection(command)
        this.destroy()
      }
    })
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
  const stash = await repo.getStash()
  const stashListView = new StashListView(stash, reference => {
    const optionsView = new StashOptionsView(reference, async command => {
      repo
        .stash(reference, command)
        .then(() =>
          atom.notifications.addSuccess(
            `stash@{${reference.index}} ${command.pastTense} successfully`,
            {
              detail: reference.label
            }
          )
        )
        .catch(error =>
          atom.notifications.addError(`There was an error popping stash@{${reference.index}}`, {
            detail: error
          })
        )
    })
    optionsView.attach()
    optionsView.focus()
  })
  stashListView.attach()
}
