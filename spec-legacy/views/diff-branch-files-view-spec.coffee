RevisionView = require '../../lib/views/git-revision-view'
DiffBranchFilesView = require '../../lib/views/diff-branch-files-view'
{repo, pathToRepoFile} = require '../fixtures'

describe "DiffBranchFilesView", ->
  textEditor = null

  beforeEach ->
    spyOn(RevisionView, 'showRevision')
    spyOn(atom.workspace, 'open').andCallFake ->
      textEditor = getPath: -> atom.workspace.open.mostRecentCall.args[0]
      Promise.resolve(textEditor)

  describe "when selectedFilePath is not provided", ->
    branchView = new DiffBranchFilesView(repo, "M\tfile.txt\nD\tanother.txt", 'branchName')

    it "displays a list of diff branch files", ->
      expect(branchView.items.length).toBe 2

    it "calls RevisionView.showRevision", ->
      waitsForPromise -> branchView.confirmSelection()
      runs ->
        expect(RevisionView.showRevision).toHaveBeenCalledWith repo, textEditor, 'branchName'

  describe "when a selectedFilePath is provided", ->
    it "does not show the view and automatically calls RevisionView.showRevision", ->
      branchView = new DiffBranchFilesView(repo, "M\tfile.txt\nD\tanother.txt", 'branchName', pathToRepoFile)
      expect(branchView.isVisible()).toBe false
      waitsFor -> RevisionView.showRevision.callCount > 0
      runs ->
        expect(RevisionView.showRevision.mostRecentCall.args[0]).toBe(repo)
        expect(RevisionView.showRevision.mostRecentCall.args[1].getPath()).toBe(pathToRepoFile)
        expect(RevisionView.showRevision.mostRecentCall.args[2]).toBe('branchName')
