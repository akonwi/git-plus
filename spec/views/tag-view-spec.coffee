git = require '../../lib/git'
{repo} = require '../fixtures'
TagView = require '../../lib/views/tag-view'

cwd = repo.getWorkingDirectory()

describe "TagView", ->
  beforeEach ->
    @tag = 'tag1'
    @view = new TagView(repo, @tag)

  it "displays 5 commands for the tag", ->
    expect(@view.items.length).toBe 5

  it "gets the remotes to push to when the push command is selected", ->
    spyOn(git, 'cmd').andCallFake -> Promise.resolve 'remotes'
    @view.confirmed(@view.items[1])
    expect(git.cmd).toHaveBeenCalledWith ['remote'], {cwd}

  it "calls git.cmd with 'checkout' to checkout the tag when checkout is selected", ->
    spyOn(git, 'cmd').andCallFake -> Promise.resolve 'success'
    @view.confirmed(@view.items[2])
    expect(git.cmd).toHaveBeenCalledWith ['checkout', @tag], {cwd}

  it "calls git.cmd with 'verify' when verify is selected", ->
    spyOn(git, 'cmd').andCallFake -> Promise.resolve 'success'
    @view.confirmed(@view.items[3])
    expect(git.cmd).toHaveBeenCalledWith ['tag', '--verify', @tag], {cwd}

  it "calls git.cmd with 'delete' when delete is selected", ->
    spyOn(git, 'cmd').andCallFake -> Promise.resolve 'success'
    @view.confirmed(@view.items[4])
    expect(git.cmd).toHaveBeenCalledWith ['tag', '--delete', @tag], {cwd}
