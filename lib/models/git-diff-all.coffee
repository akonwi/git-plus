git = require '../git'
GitDiff = require './git-diff'

gitStat = (repo) ->
  args = ['diff', '--stat']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  git.cmd
    args: args
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> GitDiff(repo, diffStat: data, file: '.')

module.exports = gitStat
