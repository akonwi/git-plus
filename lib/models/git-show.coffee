Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{CompositeDisposable} = require 'atom'
{TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'

showCommitFilePath = (objectHash) ->
  Path.join Os.tmpDir(), "#{objectHash}.diff"

isEmpty = (string) -> string is ''

showObject = (repo, objectHash, file) ->
  objectHash = if isEmpty objectHash then 'HEAD' else objectHash
  args = ['show', '--color=never']
  showFormatOption = atom.config.get 'git-plus.general.showFormat'
  args.push "--format=#{showFormatOption}" if showFormatOption != 'none'
  args.push '--word-diff' if atom.config.get 'git-plus.diffs.wordDiff'
  args.push objectHash
  args.push '--', file if file?

  git.cmd(args, cwd: repo.getWorkingDirectory())
  .then (data) -> prepFile(data, objectHash) if data.length > 0

prepFile = (text, objectHash) ->
  fs.writeFile showCommitFilePath(objectHash), text, flag: 'w+', (err) ->
    if err then notifier.addError err else showFile objectHash

showFile = (objectHash) ->
  filePath = showCommitFilePath(objectHash)
  disposables = new CompositeDisposable
  editorForDiffs = atom.workspace.getPaneItems().filter((item) -> item.getURI?()?.includes('.diff'))[0]
  if editorForDiffs?
    editorForDiffs.setText fs.readFileSync(filePath, encoding: 'utf-8')
  else
    if atom.config.get('git-plus.general.openInPane')
      splitDirection = atom.config.get('git-plus.general.splitPane')
      atom.workspace.getActivePane()["split#{splitDirection}"]()
    atom.workspace
      .open(filePath, pending: true, activatePane: true)
      .then (textBuffer) ->
        if textBuffer?
          disposables.add textBuffer.onDidDestroy ->
            disposables.dispose()
            try fs.unlinkSync filePath

class InputView extends View
  @content: ->
    @div =>
      @subview 'objectHash', new TextEditorView(mini: true, placeholderText: 'Commit hash to show. (Defaults to HEAD)')

  initialize: (@repo) ->
    @disposables = new CompositeDisposable
    @currentPane = atom.workspace.getActivePane()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @objectHash.focus()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:cancel': => @destroy()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:confirm': =>
      text = @objectHash.getModel().getText().split(' ')[0]
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
