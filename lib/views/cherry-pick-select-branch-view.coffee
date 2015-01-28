{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'

git = require '../git'
StatusView = require './status-view'
CherryPickSelectCommits = require './cherry-pick-select-commits-view'

module.exports =
class CherryPickSelectBranch extends SelectListView

  initialize: (items, @currentHead) ->
    super
    @show()
    @setItems items

    @focusFilterEditor()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

  cancelled: -> @hide()

  hide: ->
    @panel?.hide()

  viewForItem: (item) ->
    $$ ->
      @li item

  confirmed: (item) ->
    @cancel()
    args = [
      'log'
      '--cherry-pick'
      '-z'
      '--format=%H%n%an%n%ar%n%s'
      "#{@currentHead}...#{item}"
    ]

    git.cmd
      args: args
      stdout: (data) ->
        @save ?= ''
        @save += data
      exit: (exit) ->
        if exit is 0 and @save?
          new CherryPickSelectCommits(@save.split('\0')[...-1])
          @save = null
        else
          new StatusView(type: 'warning', message: "No commits available to cherry-pick.")
