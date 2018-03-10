{join} = require 'path'
{repo} = require '../fixtures'
GitEditConfig = require '../../lib/models/git-edit-config'

config = join(repo.getPath(), 'config')

describe "GitEditConfig", ->
  it "opens the exclude file", ->
    spyOn(atom.workspace, 'open')
    GitEditConfig(repo)
    expect(atom.workspace.open).toHaveBeenCalledWith config
