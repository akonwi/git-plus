git = require '../git'
SelectStageHunkFile = require '../views/select-stage-hunk-file-view'

gitStageHunk = (repo) ->
  git.unstagedFiles(repo, null,
    (data) -> new SelectStageHunkFile(repo, data)
  )

module.exports = gitStageHunk
