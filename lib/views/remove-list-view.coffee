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

  addButtons: ->
    viewButton = $$ ->
      @div class: 'buttons', =>
        @span class: 'pull-left', =>
          @button class: 'btn btn-error inline-block-tight btn-cancel-button', 'Cancel'
        @span class: 'pull-right', =>
          @button class: 'btn btn-success inline-block-tight btn-remove-button', 'Remove'
    viewButton.appendTo(this)

    @on 'click', 'button', ({target}) =>
      @complete() if $(target).hasClass('btn-remove-button')
      @cancel() if $(target).hasClass('btn-cancel-button')

  viewForItem: (item, matchedStr) ->
    $$ ->
      @li =>
        if matchedStr? then @raw(matchedStr) else @span item

  completed: (items) ->
    files = (item for item in items when item isnt '')
    @cancel()

    currentFile = git.relativize atom.workspace.getActiveEditor()?.getPath()

    atom.workspaceView.getActiveView().remove() if currentFile in files
    git.cmd
      args: ['rm', '-f'].concat(files),
      stdout: (data) ->  new StatusView(type: 'success', message: "Removed #{prettify data}")

  # cut off rm '' around the filenames.
  prettify = (data) ->
    data = data.match(/rm ('.*')/g)
    if data?.length >= 1
      for file, i in data
        data[i] = ' ' + file.match(/rm '(.*)'/)[1]
