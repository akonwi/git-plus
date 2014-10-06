{$, EditorView, View} = require 'atom'

git = require '../git'
StatusView = require '../views/status-view'

class InputView extends View
  @content: ->
    @div class: 'overlay from-top', =>
      @subview 'commandEditor', new EditorView(mini: true, placeHolderText: 'Git command and arguments')

  initialize: ->
    @currentPane = atom.workspace.getActivePane()
    atom.workspaceView.append this
    @commandEditor.focus()
    @on 'core:cancel', => @detach()
    @commandEditor.on 'core:confirm', =>
      @detach()
      args = $(this).text().split(' ')
      if args[0] is 1 then args.shift()
      git.cmd
        args: args
        stdout: (data) =>
          new StatusView(type: 'success', message: data.toString())
          atom.project.getRepo()?.refreshStatus()
          @currentPane.activate()

module.exports = -> new InputView
