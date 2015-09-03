git = require '../git'
SelectUnstageFiles = require '../views/select-unstage-files-view'

module.exports = (repo) ->
  git.stagedFiles(repo).then (data) -> new SelectUnstageFiles(repo, data)
