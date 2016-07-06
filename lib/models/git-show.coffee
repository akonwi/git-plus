Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{CompositeDisposable} = require 'atom'
{TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'

showCommitFilePath = (objectHash) ->
  Path.join Os.tmpDir(), "#{objectHash}.diff"

showObject = (repo, objectHash, file) ->
  args = ['show', '--color=never', '--format=full']
  args.push '--word-diff' if atom.config.get 'git-plus.wordDiff'
  args.push objectHash unless isEmpty objectHash
  args.push '--', file if file?

  git.cmd(args, cwd: repo.getWorkingDirectory())
  .then (data) -> prepFile(data, objectHash) if data.length > 0

isEmpty = (objectHash) ->
  objectHash.length is 1 and objectHash[0].length is 0

prepFile = (text, objectHash) ->
  fs.writeFile showCommitFilePath(objectHash), text, flag: 'w+', (err) ->
    if err then notifier.addError err else showFile objectHash

showFile = (objectHash) ->
  disposables = new CompositeDisposable
  if atom.config.get('git-plus.openInPane')
    splitDirection = atom.config.get('git-plus.splitPane')
    atom.workspace.getActivePane()["split#{splitDirection}"]()
  atom.workspace
    .open(showCommitFilePath(objectHash), activatePane: true)
    .then (textBuffer) ->
      if textBuffer?
        disposables.add textBuffer.onDidDestroy ->
          disposables.dispose()
          try fs.unlinkSync showCommitFilePath(objectHash)

class InputView extends View
  @content: ->
    @div =>
      @subview 'objectHash', new TextEditorView(mini: true, placeholderText: 'Commit hash to show')

  initialize: (@repo) ->
    @disposables = new CompositeDisposable
    @currentPane = atom.workspace.getActivePane()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @objectHash.focus()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:cancel': => @destroy()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:confirm': =>
      text = @objectHash.getModel().getText().split(' ')
      name = if text.length is 2 then text[1] else text[0]
      showObject(@repo, text)
      @destroy()

  destroy: ->
    @disposables?.dispose()
    @panel?.destroy()

module.exports = (repo, objectHash, file) ->
  if not objectHash?
    new InputView(repo)
  else
    showObject(repo, objectHash, file)
