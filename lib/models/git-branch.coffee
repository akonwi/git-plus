{$, BufferedProcess, EditorView, View} = require 'atom'
ListView = require './branch-list-view'
StatusView = require './status-view'

dir = ->
  atom.project.getRepo().getWorkingDirectory()

module.exports.gitBranches = ->
  new BufferedProcess
    command: 'git'
    args: ['branch']
    options:
      cwd: dir()
    stdout: (data) ->
      new ListView(data.toString())
    stderr: (data) ->
      alert data.toString()

class InputView extends View
  @content: ->
    @div class: 'overlay from-top', =>
      @subview 'branchEditor', new EditorView(mini: true, placeholderText: 'New branch name')

  initialize: ->
    atom.workspaceView.append this
    @branchEditor.focus()
    @branchEditor.on 'core:confirm', =>
      name = $(this).text().slice(2)
      @createBranch name
      @detach()
      # callling save will redraw statusbar and show new branch
      atom.workspaceView.focus().trigger 'core:save'

  createBranch: (name) ->
    new BufferedProcess
      command: 'git'
      args: ['checkout', '-b', name]
      options:
        cwd: dir()
      stdout: (data) ->
        new StatusView(type: 'success', message: data.toString())
      stderr: (data) ->
        new StatusView(type: 'alert', message: data.toString())

module.exports.newBranch = ->
  new InputView
