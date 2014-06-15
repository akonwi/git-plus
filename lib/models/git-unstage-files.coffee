git = require '../git'
SelectUnstageFiles = require '../views/select-unstage-files-view'

gitUnstageFiles = ->
  git.stagedFiles (data) -> new SelectUnstageFiles(data)

module.exports = gitUnstageFiles
