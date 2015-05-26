Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'

showCommitFilePath = (objectHash) ->
  Path.join Os.tmpDir(), "#{objectHash}.diff"

showObject = (repo, objectHash, file) ->
  args = ['show']
  args.push '--format=full'
  args.push '--word-diff' if atom.config.get 'git-plus.wordDiff'
  args.push objectHash
  if file?
    args.push '--'
    args.push file

  git.cmd
    args: args,
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> prepFile data, objectHash

prepFile = (text, objectHash) ->
  fs.writeFileSync showCommitFilePath(objectHash), text, flag: 'w+'
  showFile(objectHash)

showFile = (objectHash) ->
  disposables = new CompositeDisposable
  split = if atom.config.get('git-plus.openInPane') then atom.config.get('git-plus.splitPane')
  atom.workspace
    .open(showCommitFilePath(objectHash), split: split, activatePane: true)
    .done (textBuffer) =>
      if textBuffer?
        disposables.add textBuffer.onDidDestroy =>
          disposables.dispose()
          try fs.unlinkSync showCommitFilePath()

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
    @disposables?.dispose()
    @panel?.destroy()

module.exports = (repo, objectHash, file) ->
  if not objectHash?
    new InputView(showObject)
  else
    showObject(repo, objectHash, file)
