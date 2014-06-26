Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'
StatusView = require '../views/status-view'
diffFilePath = Path.join Os.tmpDir(), "atom_git_plus.diff"

gitDiff = ({diffStat, file}={}) ->
  file ?= git.relativize(atom.workspace.getActiveEditor()?.getPath())
  diffStat ?= ''
  args = ['diff']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  args.push '--word-diff' if atom.config.get 'git-plus.wordDiff'
  args.push file if diffStat is ''
  git.cmd
    args: args,
    stdout: (data) -> diffStat += data
    exit: (code) -> prepFile diffStat if code is 0

prepFile = (text) ->
  if text?.length > 0
    fs.writeFileSync diffFilePath, text, flag: 'w+'
    showFile()
  else
    new StatusView(type: 'error', message: 'Nothing to show.')

showFile = ->
  split = if atom.config.get('git-plus.openInPane') then atom.config.get('git-plus.splitPane')
  atom.workspace
    .open(diffFilePath, split: split, activatePane: true)

module.exports = gitDiff
