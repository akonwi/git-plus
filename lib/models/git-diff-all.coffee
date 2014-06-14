git = require '../git'
GitDiff = require './git-diff'

gitStat = ->
  args = ['diff', '--stat']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  git.cmd
    args: args,
    stdout: (data) -> GitDiff diffStat: data

module.exports = gitStat
