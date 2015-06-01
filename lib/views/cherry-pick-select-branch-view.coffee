{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'
CherryPickSelectCommits = require './cherry-pick-select-commits-view'

module.exports =
class CherryPickSelectBranch extends SelectListView

  initialize: (@repo, items, @currentHead) ->
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
    @panel?.destroy()

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

    repo = @repo
    git.cmd
      args: args
      cwd: repo.getWorkingDirectory()
      stdout: (data) ->
        @save ?= ''
        @save += data
      exit: (exit) ->
        if exit is 0 and @save?
          new CherryPickSelectCommits(repo, @save.split('\0')[...-1])
          @save = null
        else
          notifier.addInfo "No commits available to cherry-pick."
