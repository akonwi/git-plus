import * as React from 'react'
import * as ReactDOM from 'react-dom'
import { Root } from './Root'

export default class OutputViewContainer {
  static URI = 'git-plus://output-view'

  isDestroyed = false
  element: HTMLElement

  constructor() {
    this.element = document.createElement('div')
    this.element.classList.add('git-plus', 'output')
    this.render()
  }

  getURI() {
    return OutputViewContainer.URI
  }

  getTitle() {
    return 'Git+'
  }

  getDefaultLocation() {
    return 'bottom'
  }

  serialize() {
    return {
      deserializer: 'git-plus/output-view'
    }
  }

  async show() {
    const focusedPane = atom.workspace.getActivePane()
    await atom.workspace.open(this, { activatePane: true })
    if (focusedPane && !focusedPane.isDestroyed()) focusedPane.activate()
  }

  hide() {
    atom.workspace.hide(this)
  }

  render() {
    ReactDOM.render(<Root container={this} />, this.element)
  }

  toggle() {
    atom.workspace.toggle(this)
  }

  destroy() {
    ReactDOM.unmountComponentAtNode(this.element)
    this.element.remove()
    this.isDestroyed = true
  }
}
