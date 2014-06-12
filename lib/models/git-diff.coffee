Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'

diffFilePath = Path.join Os.tmpDir(), "atom_git_plus.diff"

gitDiff = (diffAllStat="") ->
  currentFile = atom.project.getRepo().relativize atom.workspace.getActiveEditor()?.getPath()
  args = ['diff']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  args.push '--word-diff' if atom.config.get 'git-plus.wordDiff'
  args.push currentFile if diffAllStat == ""
  git.cmd(
    args: args,
    stdout: (data) -> diffAllStat += data.toString(),
    exit: (exitCode) -> prepFile diffAllStat if exitCode == 0
  )

prepFile = (text) ->
  fs.writeFileSync diffFilePath, text, flag: 'w+'
  showFile()

showFile = ->
  split = ''
  split = 'right'  if atom.config.get 'git-plus.openInPane'
  atom.workspace
    .open(diffFilePath, split: split, activatePane: true)

module.exports = gitDiff
