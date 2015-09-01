{repo, pathToRepoFile} = require '../fixtures'
git = require '../../lib/git'
GitAdd = require '../../lib/models/git-add'

describe "GitAdd", ->
  it "calls git.add with the current file if `addAll` is false", ->
    spyOn(git, 'add')
    spyOn(atom.workspace, 'getActiveTextEditor').andCallFake ->
      getPath: -> pathToRepoFile
    GitAdd(repo)
    expect(git.add).toHaveBeenCalledWith repo, file: repo.relativize(pathToRepoFile)

  it "calls git.add without a file option if `addAll` is true", ->
    spyOn(git, 'add')
    GitAdd(repo, addAll: true)
    expect(git.add).toHaveBeenCalledWith repo
