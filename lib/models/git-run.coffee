{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'

class InputView extends View
  @content: ->
    @div =>
      @subview 'commandEditor', new TextEditorView(mini: true, placeHolderText: 'Git command and arguments')

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
      if args[0] is 1 then args.shift()
      git.cmd
        args: args
        cwd: @repo.getWorkingDirectory()
        stdout: (data) =>
          notifier.addSuccess(data.toString()) if data.toString().length > 0
          git.refresh()
          @currentPane.activate()

module.exports = (repo) -> new InputView(repo)
