Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'
GitDiff = require './git-diff'

gitStat = ->
  args = ['diff', '--stat']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  git(
    args,
    (data) -> GitDiff data.toString()
  )

module.exports = gitStat
