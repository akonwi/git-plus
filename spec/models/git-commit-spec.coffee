Path = require 'flavored-path'

git = require '../../lib/git'
GitCommit = require '../../lib/models/git-commit'

pathToRepoFile = Path.get "~/some/repository/directory/file"
mockRepo =
  getWorkingDirectory: -> Path.get "~/some/repository"
  refreshStatus: -> undefined
  relativize: (path) -> "directory/file" if path is pathToRepoFile
  repo:
    submoduleForPath: (path) -> undefined

# describe "GitCommit", ->
