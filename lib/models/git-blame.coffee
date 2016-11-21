{CompositeDisposable} = require 'atom'
Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

contextPackageFinder = require '../context-package-finder'
git = require '../git'
notifier = require '../notifier'

nothingToShow = 'Nothing to show.'

disposables = new CompositeDisposable

showFile = (filePath) ->
  if atom.config.get('git-plus.openInPane')
    splitDirection = atom.config.get('git-plus.splitPane')
    atom.workspace.getActivePane()["split#{splitDirection}"]()
  atom.workspace.open(filePath)

prepFile = (text, filePath) ->
  new Promise (resolve, reject) ->
    if text?.length is 0
      reject nothingToShow
    else
      fs.writeFile filePath, text, flag: 'w+', (err) ->
        if err then reject err else resolve true

module.exports = (repo, {file, selectOnTreeView}={}) ->
  blameFilePath = Path.join(repo.getPath(), "atom_git_plus.blame")

  if selectOnTreeView
    if path = contextPackageFinder.get()?.selectedPath
      file = repo.relativize(path)
      file = undefined if file is ''
  else
    file ?= repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())

  if not file and not selectOnTreeView
    if selectOnTreeView
      return notifier.addError "No file selected to blame"
    else
      return notifier.addError "No open file."

  args = ['blame', file]
  git.cmd(args, cwd: repo.getWorkingDirectory())
  .then (data) -> prepFile(data, blameFilePath)
  .then -> showFile blameFilePath
  .then (textEditor) ->
    disposables.add textEditor.onDidDestroy -> fs.unlink blameFilePath
  .catch (err) ->
    if err is nothingToShow
      notifier.addInfo err
    else
      notifier.addError err
