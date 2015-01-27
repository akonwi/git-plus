{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'
SelectStageHunks = require './select-stage-hunks-view'
git = require '../git'

module.exports =
class SelectStageHunkFile extends SelectListView

  initialize: (items) ->
    super
    @show()

    @setItems items
    @focusFilterEditor()

  getFilterKey: -> 'path'

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

  cancelled: -> @hide()

  hide: ->
    @panel?.hide()

  viewForItem: (item) ->
    $$ ->
      @li =>
        @div class: 'pull-right', =>
          @span class: 'inline-block highlight', item.mode
        @span class: 'text-warning', item.path

  confirmed: ({path}) ->
    @cancel()
    git.diff(
      (data) -> new SelectStageHunks(data),
      path
    )
