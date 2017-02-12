{repo, textEditor} = require '../fixtures'
GitBranchFilesView = require '../../lib/views/diff-branch-files-view'
RevisionView = require '../../lib/views/git-revision-view'

describe "GitBranchFilesView", ->
  beforeEach ->
    @branchView = new GitBranchFilesView(repo, "M\tfile.txt\nD\tanother.txt", 'branchName')
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(RevisionView, 'showRevision').andReturn Promise.resolve true

  it "displays a list of diff branch files", ->
    expect(@branchView.items.length).toBe 2

  it "calls revision view", ->
    @branchView.confirmSelection()
    waitsFor -> RevisionView.showRevision.callCount > 0
    runs ->
      expect(atom.workspace.open).toHaveBeenCalled()
      expect(RevisionView.showRevision).toHaveBeenCalledWith textEditor, 'branchName'
