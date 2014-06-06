{BufferedProcess} = require 'atom'
StatusView = require './status-view'
GitDiff = require './git-diff'
Os = require 'os'
Path = require 'path'
fs = require 'fs'


gitStat = ()->
  dir = atom.project.getRepo().getWorkingDirectory()
  currentFile = atom.workspace.getActiveEditor()?.getPath()
  args = ['diff', '--stat']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  new BufferedProcess({
    command: 'git'
    args: args
    options:
      cwd: dir
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
    stdout: (data) ->
      GitDiff data.toString()
  })


module.exports = gitStat
