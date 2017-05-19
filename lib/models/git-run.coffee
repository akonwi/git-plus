{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'

runCommand = (repo, args) ->
  view = OutputViewManager.getView()
  promise = git.cmd(args, cwd: repo.getWorkingDirectory(), {color: true})
  promise.then (data) ->
    msg = "git #{args.join(' ')} was successful"
    notifier.addSuccess(msg)
    if data?.length > 0
      view.showContent data
    else
      view.reset()
    git.refresh repo
  .catch (msg) =>
    if msg?.length > 0
      view.showContent msg
    else
      view.reset()
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
