git = require '../../lib/git'
PushBranchListView = require '../../lib/views/push-branch-list-view'
{repo} = require '../fixtures'
options = {cwd: repo.getWorkingDirectory()}
colorOptions = {color: true}

describe "PushBranchListView", ->
  beforeEach ->
    @view = new PushBranchListView(repo, "remote/branch1\nremote/branch2", "remote", '')
    spyOn(git, 'cmd').andReturn Promise.resolve 'push'

  it "has a property called result which is a promise", ->
    expect(@view.result).toBeDefined()
    expect(@view.result.then).toBeDefined()
    expect(@view.result.catch).toBeDefined()

  it "removes the 'origin/HEAD' option in the list of branches", ->
    view = new PushBranchListView(repo, "remote/branch1\nremote/branch2\norigin/HEAD", "remote", '')
    expect(view.items.length).toBe 2

  describe "when a branch option is selected", ->
    it "calls git.cmd with ['push'], the remote name, and branch name", ->
      @view.confirmSelection()

      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['push', 'remote', 'branch1'], options, colorOptions
