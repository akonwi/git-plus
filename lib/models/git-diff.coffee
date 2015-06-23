{CompositeDisposable} = require 'atom'
Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'
notifier = require '../notifier'

disposables = new CompositeDisposable
diffFilePath = null

gitDiff = (repo, {diffStat, file}={}) ->
  diffFilePath = Path.join(repo.getPath(), "atom_git_plus.diff")
  file ?= repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  if not file
    return notifier.addError "No open file. Select 'Diff All'."
  diffStat ?= ''
  args = ['diff']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  args.push '--word-diff' if atom.config.get 'git-plus.wordDiff'
  args.push file if diffStat is ''
  git.cmd
    args: args
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> diffStat += data
    exit: (code) -> prepFile diffStat if code is 0

prepFile = (text) ->
  if text?.length > 0
    fs.writeFileSync diffFilePath, text, flag: 'w+'
    showFile()
  else
    notifier.addInfo 'Nothing to show.'

showFile = ->
  atom.workspace
  .open(diffFilePath, searchAllPanes: true)
  .done (textEditor) ->
    if atom.config.get('git-plus.openInPane')
      splitPane(atom.config.get('git-plus.splitPane'), textEditor)
    else
      disposables.add textEditor.onDidDestroy =>
        fs.unlink diffFilePath

splitPane = (splitDir, oldEditor) ->
  pane = atom.workspace.paneForURI(diffFilePath)
  options = { copyActiveItem: true }
  hookEvents = (textEditor) ->
    oldEditor.destroy()
    disposables.add textEditor.onDidDestroy =>
      fs.unlink diffFilePath

  directions =
    left: =>
      pane = pane.splitLeft options
      hookEvents(pane.getActiveEditor())
    right: =>
      pane = pane.splitRight options
      hookEvents(pane.getActiveEditor())
    up: =>
      pane = pane.splitUp options
      hookEvents(pane.getActiveEditor())
    down: =>
      pane = pane.splitDown options
      hookEvents(pane.getActiveEditor())
  directions[splitDir]()
  oldEditor.destroy()

module.exports = gitDiff
