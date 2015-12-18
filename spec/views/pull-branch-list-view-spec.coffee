git = require '../../lib/git'
PullBranchListView = require '../../lib/views/pull-branch-list-view'
{repo} = require '../fixtures'
options = cwd: repo.getWorkingDirectory()

describe "PullBranchListView", ->
  beforeEach ->
    @view = new PullBranchListView(repo, "branch1\nbranch2", "remote", '')
    spyOn(git, 'cmd').andReturn Promise.resolve 'pulled'

  it "displays a list of branches and the first option is a special one for the current branch", ->
    expect(@view.items.length).toBe 3
    expect(@view.items[0].name).toEqual '== Current =='

  it "has a property called result which is a promise", ->
    expect(@view.result).toBeDefined()
    expect(@view.result.then).toBeDefined()
    expect(@view.result.catch).toBeDefined()

  describe "when the special option is selected", ->
    it "calls git.cmd with ['pull'] and remote name", ->
      @view.confirmSelection()

      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['pull', 'remote'], options

  describe "when a branch option is selected", ->
    it "calls git.cmd with ['pull'], the remote name, and branch name", ->
      @view.selectNextItemView()
      @view.confirmSelection()

      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['pull', 'remote', 'branch1'], options

  describe "when '--rebase' is passed as extraArgs", ->
    it "calls git.cmd with ['pull', '--rebase'], the remote name", ->
      view = new PullBranchListView(repo, "branch1\nbranch2", "remote", '--rebase')
      view.confirmSelection()

      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['pull', '--rebase', 'remote'], options
