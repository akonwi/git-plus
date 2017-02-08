{repo} = require '../fixtures'
git = require '../../lib/git'
GitDiffBranchFileChooser = require '../../lib/views/git-diff-branch-file-chooser'

describe "GitDiffBranchFileChooser", ->
  beforeEach ->
    @view = new GitDiffBranchFileChooser(repo, [" M\tfile.txt", " D\tanother.txt", ''])
    spyOn(git, 'cmd')

  it "displays a list of files", ->
    expect(@view.items.length).toBe 2

  it "checkouts the selected branch", ->
    @view.confirmSelection()
    @view.checkout 'name'
    waitsFor -> git.cmd.callCount > 0
    runs ->
      expect(git.cmd).toHaveBeenCalledWith ['diff', '--name-status', repo.branch, 'name'], cwd: repo.getWorkingDirectory()
