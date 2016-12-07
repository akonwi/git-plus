git = require '../git'
RebaseListView = require '../views/rebase-list-view'

module.exports = (repo) ->
  git.cmd(['branch', '--no-color'], cwd: repo.getWorkingDirectory())
  .then (data) -> new RebaseListView(repo, data)
