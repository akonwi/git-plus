// @flow
import SelectList from 'atom-select-list'

type RemoteItem = {
  name: string
}

export default class RemoteListView {
  isAttached = false
  listView: SelectList<RemoteItem>
  panel: Panel
  previouslyFocusedElement: ?HTMLElement
  result: Promise<string>

  constructor(remotes: string[]) {
    this.result = new Promise((resolve, reject) => {
      this.listView = new SelectList({
        items: remotes.map(remote => ({
          name: remote
        })),
        emptyMessage: 'No remotes for this repository',
        filterKeyForItem: item => item.name,
        elementForItem: (item, _options) => {
          const li = document.createElement('li')
          li.textContent = item.name
          return li
        },
        didCancelSelection: () => {
          this.destroy()
          this.restoreFocus()
          reject('user cancelled')
        },
        didConfirmSelection: item => {
          resolve(item.name)
          this.destroy()
        }
      })
      this.attach()
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
