git = require '../../lib/git'
{repo} = require '../fixtures'
GitStageHunk = require '../../lib/models/git-stage-hunk'

describe "GitStageHunk", ->
  it "calls git.unstagedFiles to get files to stage", ->
    spyOn(git, 'unstagedFiles').andReturn Promise.resolve 'unstagedFile.txt'
    GitStageHunk repo
    expect(git.unstagedFiles).toHaveBeenCalled()

  it "opens the view for selecting files to choose from", ->
    spyOn(git, 'unstagedFiles').andReturn Promise.resolve 'unstagedFile.txt'
    GitStageHunk(repo).then (view) ->
      expect(view).toBeDefined()
