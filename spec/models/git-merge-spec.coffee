{repo} = require '../fixtures'
git = require '../../lib/git'
GitMerge = require '../../lib/models/git-merge'

describe "GitMerge", ->

  describe ".localBranches", ->
    it "calls git.cmd with 'branch'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve ''
      GitMerge.localBranches(repo)
      expect(git.cmd).toHaveBeenCalledWith ['branch'], cwd: repo.getWorkingDirectory()

  describe ".remoteBranches", ->
    it "calls git.cmd with 'remote branch'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve ''
      GitMerge.remoteBranches(repo)
      expect(git.cmd).toHaveBeenCalledWith ['branch', '-r'], cwd: repo.getWorkingDirectory()
