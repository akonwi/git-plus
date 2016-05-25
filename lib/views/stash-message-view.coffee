{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

GitStashSave = require '../models/git-stash-save'

class InputView extends View
  @content: ->
    @div =>
      @subview 'commandEditor', new TextEditorView(mini: true, placeholderText: 'Stash message')

  initialize: (repo) ->
    disposables = new CompositeDisposable
    currentPane = atom.workspace.getActivePane()
    panel = atom.workspace.addModalPanel(item: this)
    panel.show()
    @commandEditor.focus()

    disposables.add atom.commands.add 'atom-text-editor', 'core:cancel': (e) =>
      panel?.destroy()
      currentPane.activate()
      disposables.dispose()

    disposables.add atom.commands.add 'atom-text-editor', 'core:confirm', (e) =>
      disposables.dispose()
      panel?.destroy()
      GitStashSave(repo, message: @commandEditor.getText())
      currentPane.activate()

module.exports = InputView
