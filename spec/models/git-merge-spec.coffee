{repo} = require '../fixtures'
git = require '../../lib/git'
GitMerge = require '../../lib/models/git-merge'

describe "GitMerge", ->
  describe "when called with no options", ->
    it "calls git.cmd with 'branch'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve ''
      GitMerge(repo)
      expect(git.cmd).toHaveBeenCalledWith ['branch', '--no-color'], cwd: repo.getWorkingDirectory()

  describe "when called with { remote: true } option", ->
    it "calls git.cmd with 'branch -r'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve ''
      GitMerge(repo, remote: true)
      expect(git.cmd).toHaveBeenCalledWith ['branch', '--no-color', '-r'], cwd: repo.getWorkingDirectory()
