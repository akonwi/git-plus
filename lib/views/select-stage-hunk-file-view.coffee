{$$, BufferedProcess, SelectListView} = require 'atom'
SelectStageHunks = require './select-stage-hunks-view'
git = require '../git'

module.exports =
class SelectStageHunkFile extends SelectListView

  initialize: (items) ->
    super
    @addClass 'overlay from-top'

    @setItems items
    atom.workspaceView.append this
    @focusFilterEditor()

  getFilterKey: -> 'path'

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
