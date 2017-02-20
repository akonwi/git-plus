Path = require 'path'
fs = require 'fs-plus'
git = require '../git'
notifier = require '../notifier'
BranchListView = require '../views/branch-list-view'

nothingToShow = 'Nothing to show.'

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

module.exports = (repo) ->
  disposable = null
  git.cmd(['branch', '--no-color'], cwd: repo.getWorkingDirectory())
  .then (data) -> new BranchListView data, ({name}) ->
    branchName = name
    args = ['diff', '--stat', repo.branch, name]
    git.cmd(args, cwd: repo.getWorkingDirectory())
    .then (data) ->
      diffStat = data
      diffFilePath = Path.join(repo.getPath(), "atom_git_plus.diff")
      args = ['diff', '--color=never', repo.branch, name]
      args.push '--word-diff' if atom.config.get 'git-plus.diffs.wordDiff'
      git.cmd(args, cwd: repo.getWorkingDirectory())
      .then (data) -> prepFile((diffStat ? '') + data, diffFilePath)
      .then -> showFile diffFilePath
      .then (textEditor) ->
        disposable = textEditor.onDidDestroy ->
          fs.unlink diffFilePath
          disposable?.dispose()
      .catch (err) =>
        if err is nothingToShow
          notifier.addInfo err
        else
          notifier.addError err
