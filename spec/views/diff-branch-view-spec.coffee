fs = require 'fs-plus'
{repo, pathToRepoFile, textEditor} = require '../fixtures'
git = require '../../lib/git'
GitBranchView = require '../../lib/views/diff-branch-view'

currentPane =
  splitRight: ->
diffPane =
  splitRight: -> undefined
  getActiveEditor: -> textEditor
openPromise =
  done: (cb) -> cb textEditor

describe "GitBranchView", ->
  beforeEach ->
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(fs, 'writeFile').andCallFake -> fs.writeFile.mostRecentCall.args[3]()
    spyOn(git, 'cmd').andCallFake ->
      args = git.cmd.mostRecentCall.args[0]
      if args[2] is '--stat'
        Promise.resolve 'diff stats\n'
      else
        Promise.resolve 'diffs'
    waitsForPromise ->
      GitBranchView repo 'stats'

  it "includes the diff stats in the diffs window", ->
    expect(atom.workspace.getActiveTextEditor).toHaveBeenCalled()
    expect(atom.workspace.open).toHaveBeenCalled()
    branchView = new GitBranchView(repo, 'remote_branch')
    expect(git.cmd).toHaveBeenCalledWith ['diff', '--stat', repo.branch, 'remote_branch'], cwd: repo.getWorkingDirectory()
    expect(fs.writeFile.mostRecentCall.args[1].includes 'diff stats').toBe true
