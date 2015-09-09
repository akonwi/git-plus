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

    git.cmd(args, cwd: @repo.getWorkingDirectory())
    .then (save) =>
      if save.length > 0
        new CherryPickSelectCommits(@repo, save.split('\0')[...-1])
      else
        notifier.addInfo "No commits available to cherry-pick."
