fs = require 'fs-plus'
{$$, SelectListView} = require 'atom-space-pen-views'
git = require '../git'
notifier = require '../notifier'

module.exports =
class ListView extends SelectListView
  args: ['checkout']

  initialize: (@repo, @data) ->
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

  hide: -> @panel?.destroy()

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
    git.cmd(@args.concat(branch), cwd: @repo.getWorkingDirectory())
    # command terminates with an error-ish exit code
    .catch (data) =>
      if data.includes 'error'
        notifier.addError data
      else
        notifier.addSuccess data
      atom.workspace.observeTextEditors (editor) =>
        if filepath = editor.getPath()?.toString()
          fs.exists filepath, (exists) =>
            editor.destroy() if not exists
      git.refresh()
      @currentPane.activate()
