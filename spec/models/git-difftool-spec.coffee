fs = require 'fs-plus'
Path = require 'flavored-path'
{repo, pathToRepoFile} = require '../fixtures'
git = require '../../lib/git'
GitDiffTool = require '../../lib/models/git-difftool'

describe "GitDiffTool", ->
  beforeEach ->
    atom.config.set 'git-plus.includeStagedDiff', true
    spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
    spyOn(git, 'getConfig').andReturn Promise.resolve('some-tool')
    waitsForPromise ->
      GitDiffTool repo, file: pathToRepoFile

  describe "when git-plus.includeStagedDiff config is true", ->
    it "calls git.cmd with 'diff-index HEAD -z'", ->
      expect(git.cmd).toHaveBeenCalledWith ['diff-index', 'HEAD', '-z'], cwd: repo.getWorkingDirectory()

    it "calls `git.getConfig` to check if a a difftool is set", ->
      expect(git.getConfig).toHaveBeenCalledWith 'diff.tool', repo.getWorkingDirectory()
