Path = require 'path'
Os = require 'os'

homedir = Os.homedir()
pathToRepoFile = Path.join(homedir, "some/repository/directory/file")
head = jasmine.createSpyObj('head', ['replace'])

module.exports = mocks =
  pathToRepoFile: pathToRepoFile
  pathToSampleDir: homedir

  repo:
    getPath: -> Path.join this.getWorkingDirectory(), ".git"
    getWorkingDirectory: -> Path.join(homedir, "some/repository")
    getConfigValue: (key) -> 'some-value'
    refreshStatus: -> undefined
    relativize: (path) -> if path is pathToRepoFile then "directory/file" else path
    getReferences: ->
      heads: [head]
    getShortHead: -> 'short head'
    getUpstreamBranch: -> 'refs/remotes/origin/foo'
    isPathModified: -> false
    repo:
      submoduleForPath: (path) -> undefined

  currentPane:
    isAlive: -> true
    activate: -> undefined
    destroy: -> undefined
    getItems: -> [
      getURI: -> pathToRepoFile
    ]

  commitPane:
    isAlive: -> true
    destroy: -> mocks.textEditor.destroy()
    splitRight: -> undefined
    getItems: -> [
      getURI: -> Path.join mocks.repo.getPath(), 'COMMIT_EDITMSG'
    ]

  textEditor:
    getPath: -> pathToRepoFile
    getURI: -> pathToRepoFile
    onDidDestroy: (@destroy) ->
      dispose: ->
    onDidSave: (@save) ->
      dispose: -> undefined
