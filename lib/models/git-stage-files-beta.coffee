git = require '../git'
SelectStageFiles = require '../views/select-stage-files-view-beta'

module.exports = (repo) ->
  unstagedFiles = git.unstagedFiles(repo, showUntracked: true)
  stagedFiles = git.stagedFiles(repo)
  Promise.all([unstagedFiles, stagedFiles])
  .then (data) -> new SelectStageFiles(repo, data[0].concat(data[1]))
