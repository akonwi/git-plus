#git = require '../../lib/git'
# {repo} = require '../fixtures'
GitEditGlobalConfig = require '../../lib/models/git-edit-global-config'

{open, path} = GitEditGlobalConfig
gitconfig = 'global/git/config'

describe "GitEditGlobalConfig", ->
  beforeEach ->
    spyOn(atom.workspace, 'open')
    #waitsForPromise -> GitEditGlobalConfig()

  it "finds the global git config", ->
    beforeEach ->
      spyOn(open)
      expect(open).length.toEqual(1)

  it "finds the global git config", ->
    beforeEach ->
      spyOn(path)
      expect(path).toMatch(/git.?config/)

  it "opens the global git config", ->
    expect(atom.workspace.open).toHaveBeenCalledWith(gitconfig)

###
describe "GitEditGlobalConfig", ->
  it "opens global git config", ->
    waitsForPromise ->
      atom.workspace.open(gitconfig).then (editor) ->
        expect(editor.getPath()).toContain gitconfig
###
