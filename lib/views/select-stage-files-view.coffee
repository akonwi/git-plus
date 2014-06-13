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
          @button class: 'btn btn-success inline-block-tight btn-stage-button', 'Stage'
    viewButton.appendTo(this)

    @on 'click', 'button', ({target}) =>
      @complete() if $(target).hasClass('btn-stage-button')
      @cancel() if $(target).hasClass('btn-cancel-button')

  viewForItem: (item, matchedStr) ->
    $$ ->
      @li =>
        @div class: 'pull-right', =>
          @span class: 'inline-block highlight', item.mode
        if matchedStr? then @raw(matchedStr) else @span item.path

  completed: (items) ->
    files = (item.path for item in items)
    @cancel()

    git.cmd
      args: ['add', '-f'].concat(files),
      stdout: (data) -> new StatusView(type: 'success', message: data)
