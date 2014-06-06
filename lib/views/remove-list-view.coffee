{$, $$, SelectListView, EditorView} = require 'atom'

git = require '../git'
OutputView = require './output-view'
StatusView = require './status-view'

module.exports =
class RemoveListView extends SelectListView

  initialize: (@items) ->
    super

    @on 'click', 'button', (e) =>
      @removeFiles() if $(e.target).hasClass('gp-remove-button')
      @cancel() if $(e.target).hasClass('gp-cancel-button')

    @on 'mousedown', ({target}) =>
      false if target is @list[0] or $(target).hasClass('btn')

    @addClass 'overlay from-top'
    @list.addClass 'mark-active'
    @parseData()

    viewButton = $$ ->
      @div class: 'buttons', =>
        @text ' '
        @span class: 'pull-left', =>
          @button class: 'btn btn-error inline-block-tight gp-cancel-button', 'Cancel'
        @span class: 'pull-right', =>
          @button class: 'btn btn-success inline-block-tight gp-remove-button', 'Remove'
    viewButton.appendTo(this)

  parseData: ->
    @setItems @items
    atom.workspaceView.append this
    @focusFilterEditor()

  viewForItem: (item) ->
    $$ ->
      @li item

  confirmed: (item) ->
    viewItem = @getSelectedItemView()
    if viewItem.hasClass('active')
      viewItem.removeClass('active')
    else
      viewItem.addClass('active')

  removeFiles: ->
    files = ($.map $(this).find('li.active'), (el) -> $(el).text())
    @cancel()

    dir = atom.project.getRepo().getWorkingDirectory()
    currentFile = atom.project.getRepo().relativize atom.workspace.getActiveEditor()?.getPath()

    atom.workspaceView.getActiveView().remove() if currentFile in files
    git(
      ['rm', '-f'].concat files,
      (data) ->  new StatusView(type: 'success', message: "Removed #{prettify data}")
    )

  # cut off rm '' around the filenames.
  prettify = (data) ->
    data = data.match(/rm ('.*')/g)
    if data?.length >= 1
      for file, i in data
        data[i] = ' ' + file.match(/rm '(.*)'/)[1]
