git = require '../git'
SelectStageFiles = require '../views/select-stage-files-view'

gitStageFiles = ->
  git.unstagedFiles(
    (data) -> new SelectStageFiles(data),
    true
  )

module.exports = gitStageFiles
