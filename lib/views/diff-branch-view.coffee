{CompositeDisposable} = require 'atom'
Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'
notifier = require '../notifier'
BranchListView = require './branch-list-view'
GitDiff = require '../models/git-diff'

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

module.exports =
  class DiffBranchListView extends BranchListView
    confirmed: ({name}) ->
      name = name.slice(1) if name.startsWith "*"
      args = ['diff', '--stat', @repo.branch, name]
      git.cmd(args, cwd: @repo.getWorkingDirectory())
      .then (data) =>
        diffStat = data
        diffFilePath = Path.join(@repo.getPath(), "atom_git_plus.diff")
        args = ['diff', '--color=never', @repo.branch, name]
        args.push '--word-diff' if atom.config.get 'git-plus.diffs.wordDiff'
        git.cmd(args, cwd: @repo.getWorkingDirectory())
        .then (data) -> prepFile((diffStat ? '') + data, diffFilePath)
        .then -> showFile diffFilePath
        .then (textEditor) ->
          disposables.add textEditor.onDidDestroy -> fs.unlink diffFilePath
        .catch (err) =>
          if err is nothingToShow
            notifier.addInfo err
            @cancel()
          else
            notifier.addError err
