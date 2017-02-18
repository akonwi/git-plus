{CompositeDisposable} = require 'atom'
Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'
notifier = require '../notifier'
RevisionView = require '../views/git-revision-view'

nothingToShow = 'Nothing to show.'

disposables = new CompositeDisposable

showFile = (filePath) ->
  if atom.config.get('git-plus.general.openInPane')
    splitDirection = atom.config.get('git-plus.general.splitPane')
    atom.workspace.getActivePane()["split#{splitDirection}"]()
  atom.workspace.open(filePath)

prepFile = (text, filePath) ->
  new Promise (resolve, reject) ->
    if text?.length is 0
      reject nothingToShow
    else
      fs.writeFile filePath, text, flag: 'w+', (err) ->
        if err then reject err else resolve true

splitDiff = (repo, pathToFile) ->
  atom.workspace.open(pathToFile, {
    split: 'left',
    activatePane: false,
    activateItem: true,
    searchAllPanes: false
  }).then (editor) -> RevisionView.showRevision(editor, repo.branch)

module.exports = (repo, {diffStat, file}={}) ->
  file ?= repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  if file and file isnt '.' and atom.config.get('git-plus.experimental.useSplitDiff')
    splitDiff(repo, file)
  else
    diffFilePath = Path.join(repo.getPath(), "atom_git_plus.diff")
    if not file
      return notifier.addError "No open file. Select 'Diff All'."
    args = ['diff', '--color=never']
    args.push 'HEAD' if atom.config.get 'git-plus.diffs.includeStagedDiff'
    args.push '--word-diff' if atom.config.get 'git-plus.diffs.wordDiff'
    args.push file unless diffStat
    git.cmd(args, cwd: repo.getWorkingDirectory())
    .then (data) -> prepFile((diffStat ? '') + data, diffFilePath)
    .then -> showFile diffFilePath
    .then (textEditor) ->
      disposables.add textEditor.onDidDestroy -> fs.unlink diffFilePath
    .catch (err) ->
      if err is nothingToShow
        notifier.addInfo err
      else
        notifier.addError err
