{repo} = require '../fixtures'
git = require '../../lib/git'
GitDiffBranchFileChoose = require '../../lib/models/git-diff-branch-file-choose'

describe "GitDiffBranchFileChoose", ->
  beforeEach ->
    @view = new GitDiffBranchFileChoose(repo, [" M\tfile.txt", " D\tanother.txt", ''])
    spyOn(git, 'cmd')

  it "displays a list of files", ->
    expect(@view.items.length).toBe 2

  it "checkouts the selected branch", ->
    @view.confirmSelection()
    @view.checkout 'name'
    waitsFor -> git.cmd.callCount > 0
    runs ->
      expect(git.cmd).toHaveBeenCalledWith ['diff', '--name-status', repo.branch, 'name'], cwd: repo.getWorkingDirectory()
