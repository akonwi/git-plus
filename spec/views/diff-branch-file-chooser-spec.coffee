{repo} = require '../fixtures'
git = require '../../lib/git'
DiffBranchFileChooser = require '../../lib/views/diff-branch-file-chooser'

describe "DiffBranchFileChooser", ->
  it "gets the diff for the selected branch", ->
    spyOn(git, 'cmd').andReturn Promise.resolve('')
    view = new DiffBranchFileChooser(repo, "branch1\nbranch2")
    view.confirmSelection()
    waitsFor -> git.cmd.callCount > 0
    expect(git.cmd).toHaveBeenCalledWith ['diff', '--name-status', repo.branch, 'branch1'], cwd: repo.getWorkingDirectory()
