git = require '../git'
DiffBranchFileChoose = require './git-diff-branch-file-choose'

module.exports = (repo) ->
  git.cmd(['branch', '--no-color'], cwd: repo.getWorkingDirectory())
  .then (data) -> new DiffBranchFileChoose(repo, data)
