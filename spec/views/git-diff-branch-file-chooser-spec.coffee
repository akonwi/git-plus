{repo} = require '../fixtures'
git = require '../../lib/git'
GitDiffBranchFileChooser = require '../../lib/views/git-diff-branch-file-chooser'

describe "GitDiffBranchFileChooser", ->
  beforeEach ->
    @view = new GitDiffBranchFileChooser(repo, "branch1\nbranch2")
    spyOn(git, 'cmd').andCallFake -> Promise.resolve ''

  it "displays a list of files", ->
    expect(@view.items.length).toBe 2

  it "checkouts the selected branch", ->
    @view.confirmSelection()
    @view.checkout 'name'
    waitsFor -> git.cmd.callCount > 0
    expect(git.cmd).toHaveBeenCalledWith ['diff', '--name-status', repo.branch, 'branch1'], cwd: repo.getWorkingDirectory()
