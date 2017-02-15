git = require '../git'
DiffBranchView = require '../views/diff-branch-view'

module.exports = (repo) ->
  git.cmd(['branch', '--no-color'], cwd: repo.getWorkingDirectory())
  .then (data) -> new DiffBranchView(repo, data)
