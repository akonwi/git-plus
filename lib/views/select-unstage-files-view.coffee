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

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

  cancelled: -> @hide()

  hide: ->
    @panel?.destroy()

  viewForItem: (item, matchedStr) ->
    $$ ->
      @li =>
        @div class: 'pull-right', =>
          @span class: 'inline-block highlight', item.mode
        if matchedStr? then @raw(matchedStr) else @span item.path

  completed: (items) ->
    files = (item.path for item in items)
    @cancel()

    git.cmd(['reset', 'HEAD', '--'].concat(files), cwd: @repo.getWorkingDirectory())
    .then (msg) -> notifier.addSuccess msg
    .catch (msg) -> notifier.addError msg
