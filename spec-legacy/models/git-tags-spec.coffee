{repo} = require '../fixtures'
git = require '../../lib/git'
GitTags = require '../../lib/models/git-tags'

describe "GitTags", ->
  it "calls git.cmd with 'tag' as an arg", ->
    spyOn(git, 'cmd').andReturn Promise.resolve 'data'
    GitTags(repo)
    expect(git.cmd).toHaveBeenCalledWith ['tag', '-ln'], cwd: repo.getWorkingDirectory()
