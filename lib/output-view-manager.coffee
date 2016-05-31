OutputView = require './views/output-view'

view = null

getView = ->
  if view is null
    view = new OutputView
    atom.workspace.addBottomPanel(item: view)
    view.hide()
  view

create = ->
  view?.reset()
  getView()

module.exports = {create, getView}
