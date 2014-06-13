Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'
StatusView = require '../views/status-view'
diffFilePath = Path.join Os.tmpDir(), "atom_git_plus.diff"

gitDiff = (diffAllStat="") ->
  currentFile = atom.project.relativize atom.workspace.getActiveEditor()?.getPath()
  args = ['diff']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  args.push '--word-diff' if atom.config.get 'git-plus.wordDiff'
  args.push currentFile if diffAllStat is ''
  git.cmd(
    args: args,
    stdout: (data) -> diffAllStat += data.toString(),
    exit: (exitCode) -> prepFile diffAllStat if exitCode == 0
  )

prepFile = (text) ->
  if text.length > 0
    fs.writeFileSync diffFilePath, text, flag: 'w+'
    showFile()
  else
    new StatusView(type: 'error', message: 'Nothing to show.')

showFile = ->
  split = if atom.config.get('git-plus.openInPane') then 'right' else ''
  atom.workspace
    .open(diffFilePath, split: split, activatePane: true)

module.exports = gitDiff
