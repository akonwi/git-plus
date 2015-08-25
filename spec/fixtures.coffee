Path = require 'flavored-path'

module.exports =
  pathToRepoFile: Path.get "~/some/repository/directory/file"

  repo:
    getPath: -> Path.join this.getWorkingDirectory, ".git"
    getWorkingDirectory: -> Path.get "~/some/repository"
    refreshStatus: -> undefined
    relativize: (path) -> "directory/file" if path is pathToRepoFile
    repo:
      submoduleForPath: (path) -> undefined

  workspace:
    getActivePane: ->
      {
        alive: true
        activate: -> undefined
      }
    getPanes: -> []
    open: -> { done: -> undefined }
