fs = require 'fs-plus'
{$$, SelectListView} = require 'atom-space-pen-views'
git = require '../git'
notifier = require '../notifier'

module.exports =
class ListView extends SelectListView
  args: ['checkout']

  initialize: (@repo, @data) ->
    super
    @addClass('git-branch')
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
          @span('HEAD') if current

  confirmed: ({name}) ->
    @checkout name.match(/\*?(.*)/)[1]
    @cancel()

  checkout: (branch) ->
    git.cmd(@args.concat(branch), cwd: @repo.getWorkingDirectory())
    .then (message) =>
      notifier.addSuccess message
      atom.workspace.observeTextEditors (editor) =>
        try
          path = editor.getPath()
          console.log "Git-plus: editor.getPath() returned '#{path}'"
          if filepath = path?.toString?()
            fs.exists filepath, (exists) =>
              editor.destroy() if not exists
        catch error
          notifier.addWarning "There was an error closing windows for non-existing files after the checkout. Please check the dev console."
          console.info "Git-plus: please take a screenshot of what has been printed in the console and add it to the issue on github at https://github.com/akonwi/git-plus/issues/139"
      git.refresh @repo
      @currentPane.activate()
    .catch (err) ->
      notifier.addError err
