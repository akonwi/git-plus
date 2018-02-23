{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'

class InputView extends View
  @content: ->
    @div class: 'git-branch', =>
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
      .then (message) =>
        notifier.addSuccess message
        git.refresh @repo
      .catch (err) =>
        notifier.addError err

module.exports = (repo) -> new InputView(repo)
