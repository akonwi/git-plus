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
    @currentPane = atom.workspace.getActivePane()
    atom.workspaceView.append this
    @branchEditor.focus()
    @on 'core:cancel', => @detach()
    @branchEditor.on 'core:confirm', =>
      text = $(this).text().split(' ')
      name = if text.length is 2 then text[1] else text[0]
      @createBranch name
      @detach()

  createBranch: (name) ->
    git.cmd
      args: ['checkout', '-b', name],
      stdout: (data) =>
        new StatusView(type: 'success', message: data.toString())
        atom.project.getRepo()?.refreshStatus()
        @currentPane.activate()

module.exports.newBranch = ->
  new InputView()
