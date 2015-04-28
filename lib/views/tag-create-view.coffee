Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{BufferedProcess, CompositeDisposable} = require 'atom'
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

  initialize: (@repo) ->
    @disposables = new CompositeDisposable
    @currentPane = atom.workspace.getActivePane()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @tagName.focus()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:cancel': => @destroy()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:confirm': => @createTag()

  createTag: ->
    tag = name: @tagName.getModel().getText(), message: @tagMessage.getModel().getText()
    git.cmd
      args: ['tag', '-a', tag.name, '-m', tag.message]
      cwd: @repo.getWorkingDirectory()
      stderr: (data) ->
        new StatusView(type: 'error', message: data.toString())
      exit: (code) ->
        new StatusView(type: 'success', message: "Tag '#{tag.name}' has been created successfully!") if code is 0
    @destroy()

  destroy: ->
    @panel?.destroy()
    @disposables.dispose()
    @currentPane.activate()
