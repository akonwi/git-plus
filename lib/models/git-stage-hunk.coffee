git = require '../git'
SelectStageHunkFile = require '../views/select-stage-hunk-file-view'

gitStageHunk = ->
  git.unstagedFiles(
    (data) -> new SelectStageHunkFile(data)
  )

module.exports = gitStageHunk
