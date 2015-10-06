OutputView = require './views/output-view'

view = null
module.exports =
  new: ->
    view?.reset()
    @getView()

  getView: ->
    if view is null
      view = new OutputView
      atom.workspace.addBottomPanel(item: view)
      view.hide()
    view
