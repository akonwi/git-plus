Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{BufferedProcess} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'
StatusView = require './status-view'
git = require '../git'

module.exports=
class TagCreateView extends View

  @content: ->
    @div =>
      @div class: 'block', =>
        @subview 'tagName', new TextEditorView(mini: true, placeholderText: 'Tag')
      @div class: 'block', =>
        @subview 'tagMessage', new TextEditorView(mini: true, placeholderText: 'Annotation message')
      @div class: 'block', =>
        @span class: 'pull-left', =>
          @button class: 'btn btn-success inline-block-tight gp-confirm-button', click: 'createTag', 'Create Tag'
        @span class: 'pull-right', =>
          @button class: 'btn btn-error inline-block-tight gp-cancel-button', click: 'destroy', 'Cancel'

  initialize: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @tagName.focus()
    @on 'core:cancel', => @destroy()
    @on 'core:confirm', => @createTag()

  createTag: ->
    tag = name: @tagName.getModel().getText(), message: @tagMessage.getModel().getText()
    new BufferedProcess
      command: 'git'
      args: ['tag', '-a', tag.name, '-m', tag.message]
      options:
        cwd: git.dir()
      stderr: (data) ->
        new StatusView(type: 'alert', message: data.toString())
      exit: (code) ->
        new StatusView(type: 'success', message: "Tag '#{tag.name}' has been created successfully!") if code is 0
    @destroy()

  destroy: ->
    @panel.destroy()
