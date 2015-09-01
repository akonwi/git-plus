Path = require 'flavored-path'

module.exports = mocks =
  pathToRepoFile: Path.get "~/some/repository/directory/file"

  repo:
    getPath: -> Path.join this.getWorkingDirectory, ".git"
    getWorkingDirectory: -> Path.get "~/some/repository"
    refreshStatus: -> undefined
    relativize: (path) -> "directory/file" if path is mocks.pathToRepoFile
    repo:
      submoduleForPath: (path) -> undefined

  currentPane:
    alive: true
    activate: -> undefined
    getItems: -> [
      getURI: -> mocks.pathToRepoFile
    ]

  workspace:
    getActivePane: ->
      {
        alive: true
        activate: -> undefined
      }
    getPanes: -> []
    open: -> { done: -> undefined }
