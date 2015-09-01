{repo, pathToRepoFile} = require '../fixtures'
git = require '../../lib/git'
GitDiff = require '../../lib/models/git-diff'

textEditor =
  getPath: -> pathToRepoFile
  getURI: -> pathToRepoFile

diffPane =
  splitRight: -> undefined

# describe "GitDiff", ->
#   beforeEach ->
#     atom.config.set 'git-plus.includeStagedDiff', true
#     spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
#     spyOn(atom.workspace, 'open').andReturn Promise.resolve(textEditor)
#     spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
#     waitsForPromise ->
#       GitDiff repo, file: pathToRepoFile
#
#
#   describe "when git-plus.includeStagedDiff config is true", ->
#     it "calls git.cmd and specifies 'HEAD'", ->
#       expect('HEAD' in git.cmd.mostRecentCall.args[0]).toBe true
#
#   describe "when git-plus.wordDiff config is true", ->
#     it "calls git.cmd and uses '--word-diff' flag", ->
#       atom.config.set 'git-plus.wordDiff', true
#       spyOn(git, 'cmd').andReturn Promise.resolve('diffs')
#       GitDiff repo, file: pathToRepoFile
#       expect('--word-diff' in git.cmd.mostRecentCall.args[0]).toBe true
#
#   describe "when a file is not specified", ->
#     it "checks for the current open file", ->
#       GitDiff repo
#       expect(atom.workspace.getActiveTextEditor).toHaveBeenCalled()
#
# describe "when git-plus.openInPane config is true", ->
#   beforeEach ->
#     atom.config.set 'git-plus.openInPane', true
#     spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
#     spyOn(atom.workspace, 'paneForURI').andReturn textEditor
#     spyOn(diffPane, 'splitRight')
#     waitsForPromise ->
#       GitDiff(repo)
#
#   describe "when git-plus.splitPane config is not set", ->
#     it "defaults to splitRight", ->
#       expect(diffPane.splitRight).toHaveBeenCalled()
