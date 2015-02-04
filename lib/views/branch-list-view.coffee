fs = require 'fs-plus'
{$$, SelectListView} = require 'atom-space-pen-views'

git = require '../git'
StatusView = require './status-view'

module.exports =
class ListView extends SelectListView
  initialize: (@data) ->
    super
    @show()
    @parseData()
    @currentPane = atom.workspace.getActivePane()

  parseData: ->
    items = @data.split("\n")
    branches = []
    for item in items
      item = item.replace(/\s/g, '')
      unless item is ''
        branches.push {name: item}
    @setItems branches
    @focusFilterEditor()

  getFilterKey: -> 'name'

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

  cancelled: -> @hide()

  hide: ->
    @panel?.destroy()

  viewForItem: ({name}) ->
    current = false
    if name.startsWith "*"
      name = name.slice(1)
      current = true
    $$ ->
      @li name, =>
        @div class: 'pull-right', =>
          @span('Current') if current


  confirmed: ({name}) ->
    @checkout name.match(/\*?(.*)/)[1]
    @cancel()

  checkout: (branch) ->
    git.cmd
      args: ['checkout', branch],
      stdout: (data) =>
        new StatusView(type: 'success', message: data.toString())
        atom.workspace.eachEditor (editor) ->
          fs.exists editor.getPath(), (exist) ->
            editor.destroy() if not exist
        git.refresh()
        @currentPane.activate()
