Path = require 'flavored-path'

git = require '../../lib/git'
GitAdd = require '../../lib/models/git-add'

pathToRepoFile = Path.get "~/some/repository/directory/file"
mockRepo =
  getWorkingDirectory: -> Path.get "~/some/repository"
  refreshStatus: -> undefined
  relativize: (path) -> "directory/file" if path is pathToRepoFile
  repo:
    submoduleForPath: (path) -> undefined

describe "GitAdd", ->
  it "calls git.add with the current file if `addAll` is false", ->
    spyOn(git, 'add')
    spyOn(atom.workspace, 'getActiveTextEditor').andCallFake ->
      getPath: -> pathToRepoFile

    GitAdd(mockRepo)
    expect(git.add).toHaveBeenCalledWith mockRepo, file: mockRepo.relativize(pathToRepoFile)

  it "calls git.add with '.' if `addAll` is true", ->
    spyOn(git, 'add')
    GitAdd(mockRepo, addAll: true)
    expect(git.add).toHaveBeenCalledWith mockRepo, file: null
