{BufferedProcess} = require 'atom'
StatusView = require './status-view'
Os = require 'os'
Path = require 'path'
fs = require 'fs'

diffFilePath = Path.join Os.tmpDir(), "atom_git_plus.diff"

gitDiff = (diffAllStat="") ->
  dir = atom.project.getRepo().getWorkingDirectory()
  currentFile = atom.workspace.getActiveEditor()?.getPath()
  args = ['diff']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  args.push '--word-diff' if atom.config.get 'git-plus.wordDiff'
  args.push currentFile if diffAllStat == ""
  new BufferedProcess({
    command: 'git'
    args: args
    options:
      cwd: dir
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
    stdout: (data) ->
      diffAllStat += data.toString()
    exit: (exitCode) ->
      prepFile diffAllStat if exitCode == 0
  })

prepFile = (text) ->
  fs.writeFileSync diffFilePath, text, flag: 'w+'
  showFile()

showFile = ->
  split = ''
  split = 'right'  if atom.config.get 'git-plus.openInPane'
  atom.workspace
    .open(diffFilePath, split: split, activatePane: true)

module.exports = gitDiff
