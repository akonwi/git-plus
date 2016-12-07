git = require '../git'
GitDiff = require './git-diff'

module.exports = (repo) ->
  args = ['diff', '--no-color', '--stat']
  args.push 'HEAD' if atom.config.get 'git-plus.includeStagedDiff'
  git.cmd(args, cwd: repo.getWorkingDirectory())
  .then (data) -> GitDiff(repo, diffStat: data, file: '.')
