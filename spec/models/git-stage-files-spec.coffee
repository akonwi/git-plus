git = require '../../lib/git'
{repo} = require '../fixtures'
GitStageFiles = require '../../lib/models/git-stage-files'

describe "GitStageFiles", ->
  it "calls git.unstagedFiles to get files to stage", ->
    spyOn(git, 'unstagedFiles').andReturn Promise.resolve 'unstagedFile.txt'
    GitStageFiles repo
    expect(git.unstagedFiles).toHaveBeenCalled()
