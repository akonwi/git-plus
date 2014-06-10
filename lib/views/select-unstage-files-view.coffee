{$, $$, EditorView} = require 'atom'

git = require '../git'
OutputView = require './output-view'
StatusView = require './status-view'
SelectListMultipleView = require './select-list-multiple-view'

module.exports =
class SelectStageFilesView extends SelectListMultipleView

  initialize: (items) ->
    super
    @addClass('overlay from-top')

    @setItems items
    atom.workspaceView.append(this)
    @focusFilterEditor()

  getFilterKey: ->
    'path'

  addButtons: ->
    viewButton = $$ ->
      @div class: 'buttons', =>
        @span class: 'pull-left', =>
          @button class: 'btn btn-error inline-block-tight btn-cancel-button', 'Cancel'
        @span class: 'pull-right', =>
          @button class: 'btn btn-success inline-block-tight btn-unstage-button', 'Unstage'
    viewButton.appendTo(this)

    @on 'click', 'button', ({target}) =>
      @complete() if $(target).hasClass('btn-unstage-button')
      @cancel() if $(target).hasClass('btn-cancel-button')

  viewForItem: (item) ->
    $$ ->
      @li =>
        @div class: 'pull-right', =>
          @span class: 'inline-block highlight', item.mode
        @span class: 'text-warning', item.path

  completed: (items) ->
    files = (item.path for item in items)
    @cancel()

    git(
      ['reset', 'HEAD', '--'].concat(files),
      (data) ->  new StatusView(type: 'success', message: data)
    )
