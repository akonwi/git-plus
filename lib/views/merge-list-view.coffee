fs = require 'fs-plus'
{$$, SelectListView} = require 'atom-space-pen-views'
git = require '../git'
notifier = require '../notifier'

module.exports =
class ListView extends SelectListView
  initialize: (@repo, @data) ->
    super
    @show()
    @parseData()

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
    @merge name.match(/\*?(.*)/)[1]
    @cancel()

  merge: (branch) ->
    git.cmd
      args: ['merge', branch]
      cwd: @repo.getWorkingDirectory()
      stdout: (data) =>
        notifier.addSuccess data.toString()
        atom.workspace.getTextEditors().forEach (editor) ->
          fs.exists editor.getPath(), (exist) -> editor.destroy() if not exist
        git.refresh()
