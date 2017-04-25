Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{BufferedProcess, CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'
notifier = require '../notifier'
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
    flag = if atom.config.get('git-plus.tags.signTags') then '-s' else '-a'
    git.cmd(['tag', flag, tag.name, '-m', tag.message], cwd: @repo.getWorkingDirectory())
    .then (success) ->
      console.info("Created git tag #{tag.name}:", success)
      notifier.addSuccess("Tag '#{tag.name}' has been created successfully!")
    .catch notifier.addError
    @destroy()

  destroy: ->
    @panel?.destroy()
    @disposables.dispose()
    @currentPane.activate()
