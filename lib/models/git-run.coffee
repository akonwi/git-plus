{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'

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
      view = OutputViewManager.create()
      args = @commandEditor.getText().split(' ')
      if args[0] is 1 then args.shift()
      git.cmd(args, cwd: @repo.getWorkingDirectory())
      .then (data) =>
        msg = "git #{args.join(' ')} was successful"
        notifier.addSuccess(msg)
        if data?.length > 0
          view.addLine data
        else
          view.reset()
        view.finish()
        git.refresh()
        @currentPane.activate()
      .catch (msg) =>
        if msg?.length > 0
          view.addLine msg
        else
          view.reset()
        view.finish()
        git.refresh()
        @currentPane.activate()

module.exports = (repo) -> new InputView(repo)
