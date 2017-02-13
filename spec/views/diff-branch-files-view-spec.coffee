RevisionView = require '../../lib/views/git-revision-view'
DiffBranchFilesView = require '../../lib/views/diff-branch-files-view'
{repo, textEditor} = require '../fixtures'

describe "DiffBranchFilesView", ->
  branchView = new DiffBranchFilesView(repo, "M\tfile.txt\nD\tanother.txt", 'branchName')

  beforeEach ->
    spyOn(RevisionView, 'showRevision')
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor

  it "displays a list of diff branch files", ->
    expect(branchView.items.length).toBe 2

  it "calls revision view", ->
    waitsForPromise -> branchView.confirmSelection()
    runs ->
      expect(RevisionView.showRevision).toHaveBeenCalledWith textEditor, 'branchName'
