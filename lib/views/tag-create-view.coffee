Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{$, BufferedProcess, EditorView, View} = require 'atom'
StatusView = require './status-view'
git = require '../git'

module.exports=
class TagCreateView extends View

  @content: ->
    @div class: 'overlay from-top', =>
      @div class: 'block', =>
        @subview 'tagName', new EditorView(mini: true, placeholderText: 'Tag')
      @div class: 'block', =>
        @subview 'tagMessage', new EditorView(mini: true, placeholderText: 'Annotation message')
      @div class: 'block', =>
        @span class: 'pull-left', =>
          @button class: 'btn btn-success inline-block-tight gp-confirm-button', click: 'createTag', 'Create Tag'
        @span class: 'pull-right', =>
          @button class: 'btn btn-error inline-block-tight gp-cancel-button', click: 'abort', 'Cancel'

  initialize: ->
    atom.workspaceView.append this
    @tagName.focus()
    @on 'core:cancel', => @abort()

  createTag: ->
    tag = name: @tagName.text().slice(2), message: @tagMessage.text().slice(2)
    new BufferedProcess
      command: 'git'
      args: ['tag', '-a', tag.name, '-m', tag.message]
      options:
        cwd: git.dir()
      stderr: (data) ->
        new StatusView(type: 'alert', message: data.toString())
      exit: (code) ->
        new StatusView(type: 'success', message: "Tag '#{tag.name}' has been created successfully!") if code is 0
    @detach()

  abort: ->
    @detach()
