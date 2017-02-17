git = require('../../lib/git')
{repo} = require('../fixtures')
GitCheckoutNewBranch = require('../../lib/models/git-checkout-new-branch')

describe "GitCheckoutNewBranch", ->
  inputView = null

  beforeEach ->
    spyOn(atom.workspace, 'addModalPanel').andCallThrough()
    spyOn(git, 'cmd').andReturn(Promise.resolve('new branch created'))
    inputView = GitCheckoutNewBranch(repo)

  it "displays a text input", ->
    expect(atom.workspace.addModalPanel).toHaveBeenCalled()

  describe "when the input has no text and it is submitted", ->
    it "does nothing", ->
      inputView.branchEditor.setText ''
      inputView.createBranch()
      expect(git.cmd).not.toHaveBeenCalled()

  describe "when the input has text and it is submitted", ->
    it "runs 'checkout -b' with the submitted name", ->
      branchName = 'neat/-branch'
      inputView.branchEditor.setText branchName
      inputView.createBranch()
      expect(git.cmd).toHaveBeenCalledWith ['checkout', '-b', branchName], cwd: repo.getWorkingDirectory()
