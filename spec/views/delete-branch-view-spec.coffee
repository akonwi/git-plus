git = require '../../lib/git'
{repo} = require '../fixtures'
DeleteBranchView = require '../../lib/views/delete-branch-view'

describe "DeleteBranchView", ->
  it "deletes the selected branch", ->
    spyOn(git, 'cmd').andReturn Promise.resolve 'success'
    view = new DeleteBranchView(repo, "branch/1\nbranch2")
    view.confirmSelection()
    expect(git.cmd).toHaveBeenCalledWith ['branch', '-D', 'branch/1'], cwd: repo.getWorkingDirectory()
