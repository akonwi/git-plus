git = require '../git'
DeleteBranchView = require '../views/delete-branch-view'

module.exports = (repo) ->
  git.cmd(['branch'], cwd: repo.getWorkingDirectory())
  .then (data) -> new DeleteBranchView(repo, data)
