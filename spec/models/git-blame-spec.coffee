fs = require 'fs-plus'
{repo, pathToRepoFile, textEditor} = require '../fixtures'
git = require '../../lib/git'
GitBlame = require '../../lib/models/git-blame'

currentPane =
  splitRight: ->
blamePane =
  splitRight: -> undefined
  getActiveEditor: -> textEditor
openPromise =
  done: (cb) -> cb textEditor

describe "GitBlame", ->
  beforeEach ->
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    waitsForPromise ->
      GitBlame repo, file: pathToRepoFile

  it "checks for the current open file", ->
    expect(atom.workspace.getActiveTextEditor).not.toHaveBeenCalled()


describe "GitBlame when a file is not specified", ->
  beforeEach ->
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    waitsForPromise ->
      GitBlame repo

  it "checks for the current open file", ->
    expect(atom.workspace.getActiveTextEditor).toHaveBeenCalled()
