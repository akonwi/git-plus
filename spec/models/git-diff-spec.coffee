fs = require 'fs-plus'
{repo, pathToRepoFile, textEditor} = require '../fixtures'
git = require '../../lib/git'
GitDiff = require '../../lib/models/git-diff'
GitDiffAll = require '../../lib/models/git-diff-all'
RevisionView = require '../../lib/views/git-revision-view'

currentPane =
  splitRight: ->
diffPane =
  splitRight: -> undefined
  getActiveEditor: -> textEditor
openPromise =
  done: (cb) -> cb textEditor

describe "GitDiff", ->
  beforeEach ->
    atom.config.set 'git-plus.diffs.includeStagedDiff', true
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
    waitsForPromise ->
      GitDiff repo, file: pathToRepoFile

  describe "when git-plus.diffs.includeStagedDiff config is true", ->
    it "calls git.cmd and specifies 'HEAD'", ->
      expect('HEAD' in git.cmd.mostRecentCall.args[0]).toBe true

describe "GitDiff when git-plus.diffs.wordDiff config is true", ->
  beforeEach ->
    atom.config.set 'git-plus.diffs.wordDiff', true
    atom.config.set 'git-plus.diffs.includeStagedDiff', true
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
    waitsForPromise ->
      GitDiff repo, file: pathToRepoFile

  it "calls git.cmd and uses '--word-diff' flag", ->
    expect('--word-diff' in git.cmd.mostRecentCall.args[0]).toBe true

describe "GitDiff when a file is not specified", ->
  beforeEach ->
    atom.config.set 'git-plus.diffs.includeStagedDiff', true
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
    waitsForPromise ->
      GitDiff repo

  it "checks for the current open file", ->
    expect(atom.workspace.getActiveTextEditor).toHaveBeenCalled()

describe "when the useSplitDiff config is set to true", ->
  it "calls RevisionView.showRevision", ->
    atom.config.set('git-plus.experimental.useSplitDiff', true)
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(RevisionView, 'showRevision')
    GitDiff(repo, file: pathToRepoFile)
    waitsFor -> RevisionView.showRevision.callCount > 0
    runs ->
      expect(atom.workspace.open).toHaveBeenCalled()
      expect(RevisionView.showRevision).toHaveBeenCalledWith textEditor, repo.branch

  describe "when no current repository file is open", ->
    it "notifies user that the split-diff feature won't work unless invoked on a repository file", ->
      atom.config.set('git-plus.experimental.useSplitDiff', true)
      spyOn(atom.workspace, 'open')
      spyOn(RevisionView, 'showRevision')
      GitDiff(repo)
      expect(atom.workspace.open).not.toHaveBeenCalled()
      expect(RevisionView.showRevision).not.toHaveBeenCalled()

  describe "when file option is '.'", ->
    it "does not try to use split-dif", ->
      atom.config.set('git-plus.experimental.useSplitDiff', true)
      spyOn(atom.workspace, 'open')
      spyOn(RevisionView, 'showRevision')
      GitDiff(repo, file: '.')
      expect(atom.workspace.open).not.toHaveBeenCalled()
      expect(RevisionView.showRevision).not.toHaveBeenCalled()

# describe "when git-plus.general.openInPane config is true", ->
#   beforeEach ->
#     atom.config.set 'git-plus.general.openInPane', true
#     spyOn(atom.workspace, 'getActivePane').andReturn currentPane
#     spyOn(atom.workspace, 'open').andReturn textEditor
#     spyOn(currentPane, 'splitRight').andReturn currentPane
#     waitsForPromise ->
#       GitDiff repo, file: '.'
#
#   describe "when git-plus.general.splitPane config is not set", ->
#     it "defaults to splitRight", ->
#       expect(currentPane.splitRight).toHaveBeenCalled()
#       expect(atom.workspace.getActivePane).toHaveBeenCalled()

describe "GitDiffAll", ->
  beforeEach ->
    atom.config.set 'git-plus.diffs.includeStagedDiff', true
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
      GitDiffAll repo

  it "includes the diff stats in the diffs window", ->
    expect(fs.writeFile.mostRecentCall.args[1].includes 'diff stats').toBe true
