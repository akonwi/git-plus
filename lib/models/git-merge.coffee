git = require '../git'
MergeListView = require '../views/merge-list-view'

module.exports = (repo) ->
  git.cmd(['branch'], cwd: repo.getWorkingDirectory())
  .then (data) -> new MergeListView(repo, data)
