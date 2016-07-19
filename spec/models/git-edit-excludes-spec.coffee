{repo} = require '../fixtures'
GitEditExcludes = require '../../lib/models/git-edit-excludes'

describe "GitEditExcludes", ->
  beforeEach ->
    spyOn(atom.workspace, 'open')
    waitsForPromise -> GitEditExcludes(repo)

    it "opens excludes file", ->
      expect(atom.workspace.open).toHaveBeenCalledWith('.git/info/excludes')
