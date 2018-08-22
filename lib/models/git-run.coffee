{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'
git2 = require('../git-es').default
Repository = require('../repository').default
ActivityLogger = require('../activity-logger').default

runCommand = (repo, args) ->
  repoName = new Repository(repo).getName()
  promise = git2(args, cwd: repo.getWorkingDirectory(), color: true)
  promise.then (result) ->
    ActivityLogger.record(Object.assign({repoName, message: "#{args.join(' ')}"}, result))
    git.refresh repo
  return promise

class InputView extends View
  @content: ->
    @div =>
      @subview 'commandEditor', new TextEditorView(mini: true, placeholderText: 'Git command and arguments')

  initialize: (@repo) ->
    @disposables = new CompositeDisposable
    @currentPane = atom.workspace.getActivePane()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @commandEditor.focus()

    @disposables.add atom.commands.add 'atom-text-editor', 'core:cancel': (e) =>
      @panel?.destroy()
      @currentPane.activate()
      @disposables.dispose()

    @disposables.add atom.commands.add 'atom-text-editor', 'core:confirm', (e) =>
      @disposables.dispose()
      @panel?.destroy()
      runCommand(@repo, @commandEditor.getText().split(' ')).then =>
        @currentPane.activate()
        git.refresh @repo

module.exports = (repo, args=[]) ->
  if args.length > 0
    runCommand repo, args.split(' ')
  else
    new InputView(repo)
