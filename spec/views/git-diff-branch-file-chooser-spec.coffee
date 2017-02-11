{repo} = require '../fixtures'
git = require '../../lib/git'
DiffBranchFileChooser = require '../../lib/views/diff-branch-file-chooser'

describe "DiffBranchFileChooser", ->
  beforeEach ->
    @view = new DiffBranchFileChooser(repo, "branch1\nbranch2")
    spyOn(git, 'cmd').andCallFake -> Promise.resolve ''

  it "displays a list of files", ->
    expect(@view.items.length).toBe 2

  it "checkouts the selected branch", ->
    @view.confirmSelection()
    @view.checkout 'name'
    waitsFor -> git.cmd.callCount > 0
    expect(git.cmd).toHaveBeenCalledWith ['diff', '--name-status', repo.branch, 'branch1'], cwd: repo.getWorkingDirectory()
