{$, $$, EditorView} = require 'atom-space-pen-views'

git = require '../git'
OutputView = require './output-view'
StatusView = require './status-view'
SelectListMultipleView = require './select-list-multiple-view'

module.exports =
class SelectStageFilesView extends SelectListMultipleView

  initialize: (items) ->
    super
    @show()

    @setItems items
    @focusFilterEditor()

  addButtons: ->
    viewButton = $$ ->
      @div class: 'buttons', =>
        @span class: 'pull-left', =>
          @button class: 'btn btn-error inline-block-tight btn-cancel-button', 'Cancel'
        @span class: 'pull-right', =>
          @button class: 'btn btn-success inline-block-tight btn-remove-button', 'Remove'
    viewButton.appendTo(this)

    @on 'click', 'button', ({target}) =>
      if $(target).hasClass('btn-remove-button')
        @complete() if window.confirm 'Are you sure?'
      @cancel() if $(target).hasClass('btn-cancel-button')

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

  cancelled: -> @hide()

  hide: ->
    @panel?.hide()

  viewForItem: (item, matchedStr) ->
    $$ ->
      @li =>
        if matchedStr? then @raw(matchedStr) else @span item

  completed: (items) ->
    files = (item for item in items when item isnt '')
    @cancel()

    currentFile = git.relativize atom.workspace.getActiveEditor()?.getPath()

    editor = atom.workspace.getActiveTextEditor()
    atom.views.getView(editor).remove() if currentFile in files
    git.cmd
      args: ['rm', '-f'].concat(files),
      stdout: (data) ->  new StatusView(type: 'success', message: "Removed #{prettify data}")

  # cut off rm '' around the filenames.
  prettify = (data) ->
    data = data.match(/rm ('.*')/g)
    if data?.length >= 1
      for file, i in data
        data[i] = ' ' + file.match(/rm '(.*)'/)[1]
