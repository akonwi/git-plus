{$$, BufferedProcess, SelectListView} = require 'atom'

git = require '../git'
StatusView = require './status-view'
CherryPickSelectCommits = require './cherry-pick-select-commits-view'

module.exports =
class CherryPickSelectBranch extends SelectListView

  initialize: (items, @currentHead) ->
    super
    @addClass 'overlay from-top'
    @setItems items

    atom.workspaceView.append this
    @focusFilterEditor()

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
