{$$, SelectListView} = require 'atom-space-pen-views'
git = require '../git'

module.exports =
  class ListView extends SelectListView
    initialize: (@repos) ->
      super
      @currentPane = atom.workspace.getActivePane()
      @result = new Promise (resolve, reject) =>
        @resolve = resolve
        @reject = reject
        @setup()

    getFilterKey: -> 'name'

    setup: ->
      @repos = @repos.map (r) ->
        path = r.getWorkingDirectory()
        return {
          name: path.substring(path.lastIndexOf('/')+1)
          repo: r
        }
      @setItems @repos
      @show()

    show: ->
      @filterEditorView.getModel().placeholderText = 'Which repo?'
      @panel ?= atom.workspace.addModalPanel(item: this)
      @panel.show()
      @focusFilterEditor()
      @storeFocusedElement()

    hide: -> @panel?.destroy()

    cancelled: -> @hide()

    viewForItem: ({name}) ->
      $$ -> @li(name)

    confirmed: ({repo}) ->
      @resolve repo
      @cancel()
