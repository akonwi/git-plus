{$$, SelectListView} = require 'atom-space-pen-views'

module.exports =
class ListView extends SelectListView
  initialize: (@data, @onConfirm) ->
    super
    @addClass('git-branch')
    @show()
    @parseData()
    @currentPane = atom.workspace.getActivePane()

  parseData: ->
    items = @data.split("\n")
    branches = []
    items.forEach (item) ->
      item = item.replace(/\s/g, '')
      name = if item.startsWith("*") then item.slice(1) else item
      branches.push({name}) unless item is ''
    @setItems branches
    @focusFilterEditor()

  getFilterKey: -> 'name'

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @storeFocusedElement()

  cancelled: -> @hide()

  hide: -> @panel?.destroy()

  viewForItem: ({name}) ->
    current = false
    if name.startsWith "*"
      name = name.slice(1)
      current = true
    $$ ->
      @li name, =>
        @div class: 'pull-right', =>
          @span('HEAD') if current

  confirmed: (item) ->
    @onConfirm(item)
    @cancel()
    @currentPane.activate() if @currentPane?.isAlive()
