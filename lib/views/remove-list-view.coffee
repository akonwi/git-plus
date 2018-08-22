{$, $$, EditorView} = require 'atom-space-pen-views'

git = require '../git'
ActivityLogger = require('../activity-logger').default
Repository = require('../repository').default
SelectListMultipleView = require './select-list-multiple-view'

prettify = (data) ->
  result = data.match(/rm ('.*')/g)
  if result?.length >= 1
    for file, i in result
      result[i] = ' ' + file.match(/rm '(.*)'/)[1]

module.exports =
class SelectStageFilesView extends SelectListMultipleView

  initialize: (@repo, items) ->
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

  cancelled: ->
    @hide()

  hide: ->
    @panel?.destroy()

  viewForItem: (item, matchedStr) ->
    $$ ->
      @li =>
        if matchedStr? then @raw(matchedStr) else @span item

  completed: (items) ->
    files = (item for item in items when item isnt '')
    @cancel()
    currentFile = @repo.relativize atom.workspace.getActiveTextEditor()?.getPath()

    editor = atom.workspace.getActiveTextEditor()
    atom.views.getView(editor).remove() if currentFile in files
    repoName = new Repository(@repo).getName()
    git.cmd(['rm', '-f'].concat(files), cwd: @repo.getWorkingDirectory())
    .then (data) ->
      ActivityLogger.record({repoName, message: "Remove '#{prettify(data)}'", output: data})
    .catch (data) ->
      ActivityLogger.record({repoName, message: "Remove '#{prettify(data)}'", output: data, failed: true})
