// @flow
import React from 'react'
import ReactDOM from 'react-dom'
import Root from './Root'

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
    return this.constructor.URI
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

  show() {
    atom.workspace.open(this, { activatePane: false })
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
