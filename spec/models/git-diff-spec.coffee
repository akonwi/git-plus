fs = require 'fs-plus'
{repo, pathToRepoFile, textEditor} = require '../fixtures'
git = require '../../lib/git'
GitDiff = require '../../lib/models/git-diff'
GitDiffAll = require '../../lib/models/git-diff-all'

diffPane =
  splitRight: -> undefined
  getActiveEditor: -> textEditor
openPromise =
  done: (cb) -> cb textEditor

describe "GitDiff", ->
  beforeEach ->
    atom.config.set 'git-plus.includeStagedDiff', true
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
    waitsForPromise ->
      GitDiff repo, file: pathToRepoFile

  describe "when git-plus.includeStagedDiff config is true", ->
    it "calls git.cmd and specifies 'HEAD'", ->
      expect('HEAD' in git.cmd.mostRecentCall.args[0]).toBe true

describe "GitDiff when git-plus.wordDiff config is true", ->
  beforeEach ->
    atom.config.set 'git-plus.wordDiff', true
    atom.config.set 'git-plus.includeStagedDiff', true
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
    waitsForPromise ->
      GitDiff repo, file: pathToRepoFile

  it "calls git.cmd and uses '--word-diff' flag", ->
    expect('--word-diff' in git.cmd.mostRecentCall.args[0]).toBe true

describe "GitDiff when a file is not specified", ->
  beforeEach ->
    atom.config.set 'git-plus.includeStagedDiff', true
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
    waitsForPromise ->
      GitDiff repo,

  it "checks for the current open file", ->
    expect(atom.workspace.getActiveTextEditor).toHaveBeenCalled()

describe "when git-plus.openInPane config is true", ->
  beforeEach ->
    atom.config.set 'git-plus.openInPane', true
    atom.config.set 'git-plus.splitPane', 'right'
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(atom.workspace, 'paneForURI').andReturn diffPane
    spyOn(diffPane, 'splitRight').andReturn diffPane
    spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
    waitsForPromise ->
      GitDiff(repo)

  describe "when git-plus.splitPane config is not set", ->
    it "defaults to splitRight", ->
      expect(diffPane.splitRight).toHaveBeenCalled()

describe "GitDiffAll", ->
  beforeEach ->
    atom.config.set 'git-plus.includeStagedDiff', true
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(fs, 'writeFile').andCallFake -> fs.writeFile.mostRecentCall.args[3]()
    spyOn(git, 'cmd').andCallFake ->
      args = git.cmd.mostRecentCall.args[0]
      if args[1] is '--stat'
        Promise.resolve 'diff stats\n'
      else
        Promise.resolve 'diffs'
    waitsForPromise ->
      GitDiffAll repo

  it "includes the diff stats in the diffs window", ->
    expect(fs.writeFile.mostRecentCall.args[1].includes 'diff stats').toBe true
