git = require '../git'
SelectStageFiles = require '../views/select-stage-files-view'

module.exports = (repo) ->
  git.unstagedFiles(repo, showUntracked: true)
  .then (data) -> new SelectStageFiles(repo, data)
