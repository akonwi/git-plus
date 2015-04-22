{$$, SelectListView} = require 'atom-space-pen-views'
git = require '../git'

module.exports =
  class ListView extends SelectListView
    initialize: ->
      super
      @currentPane = atom.workspace.getActivePane()
      @result = new Promise (resolve, reject) =>
        @resolve = resolve
        @reject = reject
        @setup()

    getFilterKey: -> 'path'

    setup: ->
      @setItems atom.project.getPaths().map (p) ->
        return {
          path: p
          relativized: p.substring(p.lastIndexOf('/')+1)
        }
      @show()

    show: ->
      @filterEditorView.getModel().placeholderText = 'Initialize new repo where?'
      @panel ?= atom.workspace.addModalPanel(item: this)
      @panel.show()
      @focusFilterEditor()
      @storeFocusedElement()

    hide: -> @panel?.destroy()

    cancelled: ->
      @hide()

    viewForItem: ({path, relativized}) ->
      $$ ->
        @li =>
          @div class: 'text-highlight', relativized
          @div class: 'text-info', path

    confirmed: ({path}) ->
      @resolve path
      @cancel()
