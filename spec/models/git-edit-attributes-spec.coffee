{join} = require 'path'
{repo} = require '../fixtures'
GitEditAttributes = require '../../lib/models/git-edit-attributes'

attributes = join(repo.getPath(), 'info', 'attributes')

describe "GitEditAttributes", ->
  it "opens the exclude file", ->
    spyOn(atom.workspace, 'open')
    GitEditAttributes(repo)
    expect(atom.workspace.open).toHaveBeenCalledWith attributes
