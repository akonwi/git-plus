fs = require 'fs-plus'
{repo, pathToSampleDir, pathToRepoFile} = require '../fixtures'
git = require '../../lib/git'
GitDiffTool = require '../../lib/models/git-difftool'

describe "GitDiffTool", ->
  describe "Using includeStagedDiff", ->
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

  describe "Usage on dirs", ->
    beforeEach ->
      spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
      spyOn(git, 'getConfig').andReturn Promise.resolve('some-tool')
      waitsForPromise ->
        GitDiffTool repo, file: pathToSampleDir

    describe "when file points to a directory", ->
      it "calls git.cmd with 'difftool --no-prompt -d'", ->
        expect(git.cmd.calls[1].args).toEqual([['difftool', '-d', '--no-prompt', pathToSampleDir], {cwd: repo.getWorkingDirectory()}]);

      it "calls `git.getConfig` to check if a a difftool is set", ->
        expect(git.getConfig).toHaveBeenCalledWith 'diff.tool', repo.getWorkingDirectory()
