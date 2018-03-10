{join} = require 'path'
{repo} = require '../fixtures'
GitEditExcludes = require '../../lib/models/git-edit-excludes'

excludes = join(repo.getPath(), 'info', 'exclude')

describe "GitEditExcludes", ->
  it "opens the exclude file", ->
    spyOn(atom.workspace, 'open')
    GitEditExcludes(repo)
    expect(atom.workspace.open).toHaveBeenCalledWith excludes
