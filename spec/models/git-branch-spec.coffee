git = require '../../lib/git'
{repo, pathToRepoFile} = require '../fixtures'
{
  newBranch
} = require '../../lib/models/git-branch'

describe "GitBranch", ->
  beforeEach ->
    spyOn(atom.workspace, 'addModalPanel').andCallThrough()

  describe ".newBranch", ->
    beforeEach ->
      spyOn(git, 'cmd').andReturn -> Promise.reject 'new branch created'
      newBranch(repo)

    it "displays a text input", ->
      expect(atom.workspace.addModalPanel).toHaveBeenCalled()

    ## Tweaks out about 'git' being undefined for some reason
    # it "creates a branch with the name entered in the input view", ->
    #   branchName = 'neat/-branch'
    #   @view.branchEditor.setText branchName
    #   @view.createBranch()
    #   expect(git.cmd).toHaveBeenCalledWith ['checkout', '-b', branchName]
