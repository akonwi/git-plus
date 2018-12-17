{repo} = require '../fixtures'
git = require '../../lib/git'
GitStatus = require '../../lib/models/git-status'

describe "GitStatus", ->
  beforeEach ->
    spyOn(git, 'status').andReturn Promise.resolve 'foobar'

  it "calls git.status", ->
    GitStatus(repo)
    expect(git.status).toHaveBeenCalledWith repo

  it "creates a new StatusListView", ->
    GitStatus(repo).then (view) ->
      expect(view).toBeDefined()
