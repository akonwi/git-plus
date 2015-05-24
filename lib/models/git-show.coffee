Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'

showCommitFilePath = ->
  Path.join Os.tmpDir(), "atom_git_plus_commit.diff"

showObject = (objectHash, file) ->
  args = ['show']
  args.push '--format=full'
  args.push '--word-diff' if atom.config.get 'git-plus.wordDiff'
  args.push objectHash
  if file?
    args.push '--'
    args.push file

  git.cmd
    args: args,
    stdout: (data) -> prepFile data

prepFile = (text) ->
  fs.writeFileSync showCommitFilePath(), text, flag: 'w+'
  showFile()

showFile = ->
  split = if atom.config.get('git-plus.openInPane') then atom.config.get('git-plus.splitPane')
  atom.workspace
    .open(showCommitFilePath(), split: split, activatePane: true)

class InputView extends View
  @content: ->
    @div =>
      @subview 'objectHash', new TextEditorView(mini: true, placeholderText: 'Commit hash to show')

  initialize: (callback) ->
    @disposables = new CompositeDisposable
    @currentPane = atom.workspace.getActivePane()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @objectHash.focus()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:cancel': => @destroy()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:confirm': =>
      text = @objectHash.getModel().getText().split(' ')
      name = if text.length is 2 then text[1] else text[0]
      callback text
      @destroy()

  destroy: ->
    @panel.destroy()

module.exports = (objectHash, file) ->
  if not objectHash?
    new InputView(showObject)
  else
    showObject(objectHash, file)
