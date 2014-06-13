{$, EditorView, View} = require 'atom'

git = require '../git'
StatusView = require '../views/status-view'
BranchListView = require '../views/branch-list-view'

module.exports.gitBranches = ->
  git.cmd
    args: ['branch'],
    stdout: (data) ->
      new BranchListView data

class InputView extends View
  @content: ->
    @div class: 'overlay from-top', =>
      @subview 'branchEditor', new EditorView(mini: true, placeholderText: 'New branch name')

  initialize: ->
    atom.workspaceView.append this
    @branchEditor.focus()
    @branchEditor.on 'core:confirm', =>
      name = $(this).text().slice(2)
      @createBranch name
      @detach()
      # callling save will redraw statusbar and show new branch
      atom.workspaceView.focus().trigger 'core:save'

  createBranch: (name) ->
    git.cmd
      args: ['checkout', '-b', name],
      stdout: (data) -> new StatusView(type: 'success', message: data.toString())

module.exports.newBranch = ->
  new InputView()
