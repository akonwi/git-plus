git = require '../../lib/git'
{repo, pathToRepoFile, textEditor, currentPane} = require '../fixtures'
GitRemove = require '../../lib/models/git-remove'

describe "GitRemove", ->
  it "calls git.cmd with 'rm' and #{pathToRepoFile}", ->
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn textEditor
    spyOn(atom.workspace, 'getActivePaneItem').andReturn currentPane
    spyOn(window, 'confirm').andReturn true
    spyOn(git, 'cmd').andReturn Promise.resolve repo.relativize(pathToRepoFile)
    GitRemove repo
    args = git.cmd.mostRecentCall.args[0]
    expect('rm' in args).toBe true
    expect(repo.relativize(pathToRepoFile) in args).toBe true
