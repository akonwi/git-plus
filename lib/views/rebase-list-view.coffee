fs = require 'fs-plus'
{$$, SelectListView} = require 'atom-space-pen-views'
git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'

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
      @rebase name.match(/\*?(.*)/)[1]
      @cancel()

    rebase: (branch) ->
      git.cmd(['rebase', branch], cwd: @repo.getWorkingDirectory())
      .then (msg) ->
        OutputViewManager.new().addLine(msg).finish()
        atom.workspace.getTextEditors().forEach (editor) ->
          fs.exists editor.getPath(), (exist) -> editor.destroy() if not exist
        git.refresh()
      .catch (msg) =>
        notifier.addError msg
        git.refresh()
