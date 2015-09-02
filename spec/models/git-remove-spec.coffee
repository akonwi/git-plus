git = require '../../lib/git'
{repo, pathToRepoFile, textEditor, currentPane} = require '../fixtures'
GitRemove = require '../../lib/models/git-remove'

describe "GitRemove", ->
  beforeEach ->
      spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
      spyOn(atom.workspace, 'getActivePaneItem').andReturn currentPane
      spyOn(window, 'confirm').andReturn true
      spyOn(git, 'cmd').andReturn Promise.resolve repo.relativize(pathToRepoFile)

  describe "when there is a current file open", ->
    it "calls git.cmd with 'rm' and #{pathToRepoFile}", ->
      GitRemove repo
      args = git.cmd.mostRecentCall.args[0]
      expect('rm' in args).toBe true
      expect(repo.relativize(pathToRepoFile) in args).toBe true

  describe "when 'showSelector' is set to true", ->
    it "calls git.cmd with '*' instead of #{pathToRepoFile}", ->
      GitRemove repo, showSelector: true
      args = git.cmd.mostRecentCall.args[0]
      expect('*' in args).toBe true
