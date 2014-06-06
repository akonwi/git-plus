{$, $$, BufferedProcess, SelectListView, EditorView} = require 'atom'
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
    dir = atom.project.getRepo().getWorkingDirectory()
    files = $.map $('.active'), (el) -> $(el).text()
    @cancel()

    new BufferedProcess({
      command: 'git'
      args: ['rm', '-f'].concat files[1..]
      options:
        cwd: dir
      stdout: (data) ->
        new StatusView(type: 'success', message: "Removed #{prettify data}")
      stderr: (data) ->
        new StatusView(type: 'alert', message: data.toString())
    })

prettify = (data) ->
  data = data.match(/rm '(.*)'/g)
  for file, i in data
    data[i] = ' ' + file.match(/rm '(.*)'/)[1]
