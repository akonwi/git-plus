git = require '../../lib/git'
PullBranchListView = require '../../lib/views/pull-branch-list-view'
{repo} = require '../fixtures'
options = {cwd: repo.getWorkingDirectory()}
colorOptions = {color: true}

describe "PullBranchListView", ->
  beforeEach ->
    @view = new PullBranchListView(repo, "remote/branch1\nremote/branch2", "remote", '')
    spyOn(git, 'cmd').andReturn Promise.resolve 'pulled'

  it "displays a list of branches and the first option is a special one for the current branch", ->
    expect(@view.items.length).toBe 2

  it "has a property called result, which is a resolved with the selected branch name", ->
    @view.confirmSelection()
    waitsForPromise => @view.result
    runs =>
      @view.result.then (branch) ->
        expect(branch).toBe 'branch1'

  it "removes the 'origin/HEAD' option in the list of branches", ->
    view = new PullBranchListView(repo, "origin/branch1\norigin/branch2\norigin/HEAD", "origin", '')
    expect(view.items.length).toBe 2

  it "only shows branches from the selected remote", ->
    view = new PullBranchListView(repo, "remote/master\nremote/foo\norigin/master", "remote", '')
    expect(view.items.length).toBe 2

  describe "when a branch option is selected", ->
    it "calls git.cmd with ['pull'], the remote name, and branch name", ->
      @view.confirmSelection()

      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['pull', 'remote', 'branch1'], options, colorOptions

  describe "when '--rebase' is passed as extraArgs", ->
    it "calls git.cmd with ['pull', '--rebase'], the remote name", ->
      view = new PullBranchListView(repo, "remote/branch1\nremote/branch2", "remote", '--rebase')
      view.confirmSelection()

      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['pull', '--rebase', 'remote', 'branch1'], options, colorOptions
