// @flow
import React from 'react'
import ReactDOM from 'react-dom'
import Root from './Root'

export default class OutputViewContainer {
  isVisible = false
  element: HTMLElement

  constructor() {
    this.element = document.createElement('div')
    this.element.classList.add('git-plus', 'output')
    this.render()
    this.show()
  }

  getTitle() {
    return 'Git+'
  }

  getDefaultLocation() {
    return 'bottom'
  }

  show() {
    if (!this.isVisible || atom.config.get('git-plus.general.alwaysOpenDockWithResult')) {
      atom.workspace.open(this).then(() => {
        this.isVisible = true
        atom.workspace.getBottomDock().show()
      })
    }
  }

  hide() {
    atom.workspace.hide(this)
    this.isVisible = false
  }

  render() {
    ReactDOM.render(<Root />, this.element)
  }

  destroy() {
    ReactDOM.unmountComponentAtNode(this.element)
    this.element.remove()
  }
}
