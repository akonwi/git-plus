quibble = require 'quibble'
{repo} = require '../fixtures'
git = require '../../lib/git'
GitDiffBranches = require '../../lib/models/git-diff-branches'
BranchListView = require '../../lib/views/branch-list-view'

repo.branch = 'master'
branches = 'foobar'

describe "GitDiffBranches", ->
  beforeEach ->
    spyOn(git, 'cmd').andReturn Promise.resolve(branches)
    spyOn(atom.workspace, 'open')

  it "gets the branches", ->
    GitDiffBranches(repo)
    expect(git.cmd).toHaveBeenCalledWith ['branch', '--no-color'], cwd: repo.getWorkingDirectory()

  it "creates a BranchListView with a callback to do the diffing when a branch is selected", ->
    view = null
    waitsForPromise -> GitDiffBranches(repo).then (v) -> view = v
    runs ->
      expect(view instanceof BranchListView).toBe true
      view.confirmSelection()
      waitsFor -> atom.workspace.open.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['diff', '--stat', repo.branch, 'foobar'], {cwd: repo.getWorkingDirectory()}
        expect(atom.workspace.open).toHaveBeenCalledWith(repo.getPath() + '/atom_git_plus.diff')
