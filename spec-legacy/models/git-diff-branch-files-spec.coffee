{repo} = require '../fixtures'
git = require '../../lib/git'
GitDiffBranchFiles = require '../../lib/models/git-diff-branch-files'
BranchListView = require '../../lib/views/branch-list-view'

repo.branch = 'branch'

describe "GitDiffBranchFiles", ->
  beforeEach ->
    spyOn(git, 'cmd').andReturn Promise.resolve 'foobar'

  it "gets the branches", ->
    GitDiffBranchFiles(repo)
    expect(git.cmd).toHaveBeenCalledWith ['branch', '--no-color'], cwd: repo.getWorkingDirectory()

  it "creates a BranchListView", ->
    view = null
    waitsForPromise -> GitDiffBranchFiles(repo).then (v) -> view = v
    runs ->
      expect(view instanceof BranchListView).toBe true
      view.confirmSelection()
      waitsFor -> git.cmd.callCount > 1
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['diff', '--name-status', repo.branch, 'foobar'], cwd: repo.getWorkingDirectory()
