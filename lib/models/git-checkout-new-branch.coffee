{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'
git = require '../git'
ActivityLogger = require('../activity-logger').default
Repository = require('../repository').default

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
      message = """checkout to new branch '#{name}'"""
      repoName = new Repository(@repo).getName()
      git.cmd(['checkout', '-b', name], cwd: @repo.getWorkingDirectory())
      .then (output) =>
        ActivityLogger.record({repoName, message, output})
        git.refresh @repo
      .catch (err) =>
        ActivityLogger.record({repoName, message, output: err, failed: true})

module.exports = (repo) -> new InputView(repo)
