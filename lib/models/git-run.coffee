{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'

runCommand = (args, workingDirectory) ->
  view = OutputViewManager.create()
  promise = git.cmd(args, cwd: workingDirectory, {color: true})
  promise
  .then (data) ->
    msg = "git #{args.join(' ')} was successful"
    notifier.addSuccess(msg)
    if data?.length > 0
      view.setContent data
    else
      view.reset()
    view.finish()
  .catch (msg) =>
    if msg?.length > 0
      view.setContent msg
    else
      view.reset()
    view.finish()
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
      args = @commandEditor.getText().split(' ')
      # TODO: remove this?
      if args[0] is 1 then args.shift()
      runCommand args, @repo.getWorkingDirectory()
      .then =>
        @currentPane.activate()
        git.refresh @repo

module.exports = (repo, args) ->
  if args
    args = args.split(' ')
    runCommand args, repo.getWorkingDirectory()
  else
    new InputView(repo)
