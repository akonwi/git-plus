git = require '../../lib/git'
GitInit = require '../../lib/models/git-init'

describe "GitInit", ->
  it "sets the project path to the new repo path", ->
    spyOn(atom.project, 'setPaths')
    spyOn(atom.project, 'getPaths').andCallFake -> ['some/path']
    spyOn(git, 'cmd').andCallFake ->
      Promise.resolve true
    waitsForPromise ->
      GitInit().then ->
        expect(atom.project.setPaths).toHaveBeenCalledWith ['some/path']
