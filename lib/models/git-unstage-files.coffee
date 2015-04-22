git = require '../git'
SelectUnstageFiles = require '../views/select-unstage-files-view'

gitUnstageFiles = (repo) ->
  git.stagedFiles repo, (data) -> new SelectUnstageFiles(repo, data)

module.exports = gitUnstageFiles
