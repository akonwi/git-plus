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
    @panel = atom.workspace.addModalPanel(item: this)
    @panel.show()

    @branchEditor.focus()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:cancel': (event) => @destroy()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:confirm': (event) => @createBranch()

  destroy: ->
    @panel.destroy()
    @disposables.dispose()
    @currentPane.activate()

  createBranch: ->
    @destroy()
    name = @branchEditor.getModel().getText()
    if name.length > 0
      git.cmd(['checkout', '-b', name], cwd: @repo.getWorkingDirectory())
      .then (message) ->
        notifier.addSuccess message
        git.refresh()
      .catch (err) =>
        notifier.addError err

module.exports.newBranch = (repo) ->
  new InputView(repo)

module.exports.gitBranches = (repo) ->
  git.cmd(['branch', '--no-color'], cwd: repo.getWorkingDirectory())
  .then (data) -> new BranchListView(repo, data)

module.exports.gitRemoteBranches = (repo) ->
  git.cmd(['branch', '-r', '--no-color'], cwd: repo.getWorkingDirectory())
  .then (data) -> new RemoteBranchListView(repo, data)
