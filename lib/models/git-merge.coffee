git = require '../git'
MergeListView = require '../views/merge-list-view'

module.exports.localBranches = (repo) ->
  git.cmd(['branch'], cwd: repo.getWorkingDirectory())
  .then (data) -> new MergeListView(repo, data)

module.exports.remoteBranches = (repo) ->
  git.cmd(['branch', '-r'], cwd: repo.getWorkingDirectory())
  .then (data) -> new MergeListView(repo, data)
