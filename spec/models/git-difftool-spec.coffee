fs = require 'fs-plus'
{repo, pathToRepoFile, textEditor} = require '../fixtures'
git = require '../../lib/git'
GitDiffTool = require '../../lib/models/git-difftool'

diffPane =
  splitRight: -> undefined
  getActiveEditor: -> textEditor
openPromise =
  done: (cb) -> cb textEditor

describe "GitDiffTool", ->
  # beforeEach ->
  #   atom.config.set 'git-plus.includeStagedDiff', true
  #   spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
  #   spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
  #   spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
  #   waitsForPromise ->
  #     GitDiff repo, file: pathToRepoFile

  describe "when git-plus.includeStagedDiff config is true", ->
    it "calls git.cmd with 'diff-index HEAD -z'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
      GitDiffTool repo, file: 'blah'
      expect(git.cmd).toHaveBeenCalledWith ['diff-index', 'HEAD', '-z'], cwd: repo.getWorkingDirectory()
