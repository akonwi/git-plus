const AnsiToHtml = require('ansi-to-html')
const ansiToHtml = new AnsiToHtml()

const defaultMessage = 'Nothing new to show'

class OutputView {
  constructor() {
    this.element = document.createElement('div')
    this.element.classList.add('git-plus', 'info-view')
    const output = document.createElement('pre')
    output.id = 'content'
    output.innerHTML = defaultMessage
    this.element.appendChild(output)
  }

  getTitle() { return 'Git+' }

  getDefaultLocation() { return 'bottom' }

  reset() {
    this.element.querySelector('#content').innerHTML = defaultMessage
  }

  show() {
    if (!this.isVisible) {
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

  showContent(content) {
    this.element.querySelector('#content').innerHTML = ansiToHtml.toHtml(content)
    this.show()
  }

  toggle() {
    this.isVisible ? this.hide() : this.show()
  }
}

module.exports = OutputView
