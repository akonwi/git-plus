Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{$, EditorView, View} = require 'atom'

git = require '../git'
ListView = require '../views/branch-list-view'

showCommitFilePath = ->
  Path.join Os.tmpDir(), "atom_git_plus_commit.diff"

showObject = (objectHash, file) ->
  args = ['show']
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
    @div class: 'overlay from-top', =>
      @subview 'objectHash', new EditorView(mini: true, placeholderText: 'Commit hash to show')

  initialize: (callback) ->
    atom.workspaceView.append this
    @objectHash.focus()
    @objectHash.on 'core:confirm', =>
      object = $(this).text().slice(2)
      callback object
      @detach()

module.exports = (objectHash, file) ->
  if not objectHash?
    new InputView(showObject)
  else
    showObject(objectHash, file)
