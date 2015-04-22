git = require '../git'
SelectStageFiles = require '../views/select-stage-files-view'

gitStageFiles = (repo) ->
  git.unstagedFiles(repo,
    showUntracked: true,
    (data) -> new SelectStageFiles(repo, data)
  )

module.exports = gitStageFiles
