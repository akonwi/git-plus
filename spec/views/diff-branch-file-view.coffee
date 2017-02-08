fs = require 'fs-plus'
{repo, pathToRepoFile, textEditor} = require '../fixtures'
git = require '../../lib/git'
GitBranchFilesView = require '../../lib/views/git-branch-files-view'
RevisionView = require '../../lib/views/git-revision-view'

currentPane =
  splitRight: ->
diffPane =
  splitRight: -> undefined
  getActiveEditor: -> textEditor
openPromise =
  done: (cb) -> cb textEditor

describe "GitBranchFilesView", ->
  beforeEach ->
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(RevisionView, 'showRevision').andReturn Promise.resolve true
    spyOn(fs, 'writeFile').andCallFake -> fs.writeFile.mostRecentCall.args[3]()
    waitsForPromise ->
      GitBranchFilesView repo, 'data', 'remote_branch'

  it "includes the diff stats in the diffs window", ->
    expect(atom.workspace.getActiveTextEditor).toHaveBeenCalled()
    expect(atom.workspace.open).toHaveBeenCalled()
    branchView = new GitBranchFilesView(repo, 'data', 'remote_branch')
    expect(fs.writeFile.mostRecentCall.args[1].includes 'data').toBe true
    waitsFor ->
      RevisionView.showRevision.callCount > 0
    runs ->
      expect(RevisionView.showRevision).toHaveBeenCalledWith textEditor, 'remote_branch', {type: ''}
