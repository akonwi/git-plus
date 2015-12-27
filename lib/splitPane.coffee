module.exports = (splitDirection, oldEditor) ->
  pane = atom.workspace.paneForURI(oldEditor.getURI())
  options = { copyActiveItem: true }
  directions =
    left: ->
      pane.splitLeft options
    right: ->
      pane.splitRight options
    up: ->
      pane.splitUp options
    down: ->
      pane.splitDown options
  pane = directions[splitDirection]().getActiveEditor()
  oldEditor.destroy()
  pane
