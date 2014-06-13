{$, $$, EditorView, BufferedProcess} = require 'atom'

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

  dir = -> atom.project.getRepo()?.getWorkingDirectory() ? atom.project.getPath()

  getFilterKey: ->
    'path'

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

  viewForItem: (item) ->
    $$ ->
      @li item

  completed: (items) ->
    files = (item for item in items when item isnt '')
    @cancel()

    currentFile = atom.project.relativize atom.workspace.getActiveEditor()?.getPath()
    atom.workspaceView.getActiveView().remove() if currentFile in files

    new BufferedProcess({
      command: 'git'
      args: ['rm', '-f'].concat(files)
      options:
        cwd: dir()
      stdout: (data) ->
        new StatusView(type: 'success', message: "Removed #{prettify data}")
      stderr: (data) ->
        new StatusView(type: 'alert', message: data.toString())
    })

  # cut off rm '' around the filenames.
  prettify = (data) ->
    data = data.match(/rm ('.*')/g)
    if data?.length >= 1
      for file, i in data
        data[i] = ' ' + file.match(/rm '(.*)'/)[1]
