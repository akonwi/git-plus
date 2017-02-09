fs = require 'fs-plus'
{repo, pathToRepoFile, textEditor} = require '../fixtures'
git = require '../../lib/git'
GitBranchView = require '../../lib/views/diff-branch-view'

describe "GitBranchView", ->
  beforeEach ->
    @branchView = new GitBranchView(repo, "branch1\nbranch2")
    spyOn(atom.workspace, 'open')
    spyOn(git, 'cmd').andReturn Promise.resolve 'foobar'
    spyOn(fs, 'stat').andCallFake ->
      stat = isDirectory: -> false
      fs.stat.mostRecentCall.args[1](null, stat)

  it "displays a list of diff branch files", ->
    expect(@branchView.items.length).toBe 2

  it "calls git diff and opens file", ->
    @branchView.confirmSelection()
    waitsFor -> git.cmd.callCount > 1
    runs ->
      expect(git.cmd).toHaveBeenCalledWith ['diff', '--stat', repo.branch, 'branch1'], {cwd: repo.getWorkingDirectory()}
      expect(atom.workspace.open).toHaveBeenCalled()
