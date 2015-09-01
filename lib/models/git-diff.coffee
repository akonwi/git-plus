{CompositeDisposable} = require 'atom'
Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'
notifier = require '../notifier'

disposables = new CompositeDisposable

module.exports = (repo, {diffStat, file}={}) ->
  diffFilePath = Path.join(repo.getPath(), "atom_git_plus.diff")
  file ?= repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  if not file
    return notifier.addError "No open file. Select 'Diff All'."
  diffStat ?= ''
  args = ['diff', '--color=never']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  args.push '--word-diff' if atom.config.get 'git-plus.wordDiff'
  args.push file if diffStat is ''
  git.cmd(args, cwd: repo.getWorkingDirectory())
  .then (data) -> prepFile data, diffFilePath
  .then -> showFile diffFilePath
  .then (textEditor) -> disposables.add textEditor.onDidDestroy ->
    fs.unlink diffFilePath
  .catch (message) -> notifer.addInfo message

prepFile = (text, filePath) ->
  new Promise (resolve, reject) ->
    if text?.length is 0
      reject 'Nothing to show.'
    else
      fs.writeFile filePath, text, flag: 'w+', (err) ->
        if err
          reject err
        else
          resolve true

showFile = (filePath) ->
  atom.workspace.open(filePath, searchAllPanes: true).done (textEditor) ->
    if atom.config.get('git-plus.openInPane')
      splitPane(atom.config.get('git-plus.splitPane'), textEditor)
    else
      textEditor

splitPane = (splitDir, oldEditor) ->
  pane = atom.workspace.paneForURI(oldEditor.getURI())
  options = { copyActiveItem: true }
  directions =
    left: ->
      pane.splitLeft options
    right: ->
      pane.splitRight options
    up: ->
      pane.splitUp options
    down: ->
      pane.splitDown options
  pane = directions[splitDir]().getActiveEditor()
  oldEditor.destroy()
  pane
