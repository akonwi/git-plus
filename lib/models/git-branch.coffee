{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'
BranchListView = require '../views/branch-list-view'
RemoteBranchListView = require '../views/remote-branch-list-view'

class InputView extends View
  @content: ->
    @div =>
      @subview 'branchEditor', new TextEditorView(mini: true, placeholderText: 'New branch name')

  initialize: (@repo) ->
    @disposables = new CompositeDisposable
    @currentPane = atom.workspace.getActivePane()
    panel = atom.workspace.addModalPanel(item: this)
    panel.show()

    destroy = =>
      panel.destroy()
      @disposables.dispose()
      @currentPane.activate()

    @branchEditor.focus()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:cancel': (event) -> destroy()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:confirm': (event) =>
      editor = @branchEditor.getModel()
      name = editor.getText()
      if name.length > 0
        @createBranch name
        destroy()

  createBranch: (name) ->
    git.cmd
      args: ['checkout', '-b', name]
      cwd: @repo.getWorkingDirectory()
      # using `stderr` for success
      stderr: (data) =>
        notifier.addSuccess data.toString()
        git.refresh()
        @currentPane.activate()

module.exports.newBranch = (repo) ->
  new InputView(repo)

module.exports.gitBranches = (repo) ->
  git.cmd
    args: ['branch']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      new BranchListView(repo, data)

module.exports.gitRemoteBranches = (repo) ->
  git.cmd
    args: ['branch', '-r']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      new RemoteBranchListView(repo, data)
