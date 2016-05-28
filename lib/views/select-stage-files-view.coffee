{$, $$} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'
SelectListMultipleView = require './select-list-multiple-view'

module.exports =
class SelectStageFilesView extends SelectListMultipleView

  initialize: (@repo, items) ->
    super
    @show()
    @setItems items
    @focusFilterEditor()

  getFilterKey: -> 'path'

  addButtons: ->
    viewButton = $$ ->
      @div class: 'select-list-buttons', =>
        @div =>
          @button class: 'btn btn-error inline-block-tight btn-cancel-button', 'Cancel'
        @div =>
          @button class: 'btn btn-success inline-block-tight btn-stage-button', 'Stage'
    viewButton.appendTo(this)

    @on 'click', 'button', ({target}) =>
      @complete() if $(target).hasClass('btn-stage-button')
      @cancel() if $(target).hasClass('btn-cancel-button')

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @storeFocusedElement()

  cancelled: -> @hide()

  hide: -> @panel?.destroy()

  viewForItem: (item, matchedStr) ->
    $$ ->
      @li =>
        @div class: 'pull-right', =>
          @span class: 'inline-block highlight', item.mode
        if matchedStr? then @raw(matchedStr) else @span item.path

  completed: (items) ->
    files = (item.path for item in items)
    @cancel()
    git.cmd(['add', '-f'].concat(files), cwd: @repo.getWorkingDirectory())
    .then (data) ->
      if data is ''
        notifier.addSuccess 'File(s) staged successfully'
      else
        notifier.addSuccess data
