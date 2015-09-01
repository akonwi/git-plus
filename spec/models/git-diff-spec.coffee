{repo, pathToRepoFile} = require '../fixtures'
git = require '../../lib/git'
GitDiff = require '../../lib/models/git-diff'

describe "GitDiff", ->
  describe "when git-plus.includeStagedDiff config is true", ->
    it "calls git.cmd and specifies 'HEAD'", ->
      atom.config.set 'git-plus.includeStagedDiff', true
      spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
      GitDiff repo, file: pathToRepoFile
      expect('HEAD' in git.cmd.mostRecentCall.args[0]).toBe true

  describe "when git-plus.wordDiff config is true", ->
    it "calls git.cmd and uses '--word-diff' flag", ->
      atom.config.set 'git-plus.wordDiff', true
      spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
      GitDiff repo, file: pathToRepoFile
      expect('--word-diff' in git.cmd.mostRecentCall.args[0]).toBe true
