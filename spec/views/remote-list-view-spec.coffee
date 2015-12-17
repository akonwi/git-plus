git = require '../../lib/git'
RemoteListView = require '../../lib/views/remote-list-view'
{repo} = require '../fixtures'
options = {cwd: repo.getWorkingDirectory()}
remotes = "remote1\nremote2"

describe "RemoteListView", ->
  it "displays a list of remotes", ->
    view = new RemoteListView(repo, remotes, mode: 'pull')
    expect(view.items.length).toBe 2

  describe "when mode is pull", ->
    it "it calls git.cmd to get the remote branches", ->
      view = new RemoteListView(repo, remotes, mode: 'pull')
      spyOn(git, 'cmd').andCallFake ->
        Promise.resolve 'branch1\nbranch2'

      view.confirmSelection()
      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['branch', '-r'], options

  describe "when mode is fetch", ->
    it "it calls git.cmd to with ['fetch'] and the remote name", ->
      spyOn(git, 'cmd').andCallFake ->
        Promise.resolve 'fetched stuff'

      view = new RemoteListView(repo, remotes, mode: 'fetch')
      view.confirmSelection()
      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['fetch', 'remote1'], options

  describe "when mode is fetch-prune", ->
    it "it calls git.cmd to with ['fetch', '--prune'] and the remote name", ->
      spyOn(git, 'cmd').andCallFake ->
        Promise.resolve 'fetched stuff'

      view = new RemoteListView(repo, remotes, mode: 'fetch-prune')
      view.confirmSelection()
      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['fetch', '--prune', 'remote1'], options

  describe "when mode is push", ->
    it "calls git.cmd with ['push']", ->
      spyOn(git, 'cmd').andCallFake -> Promise.resolve 'pushing text'

      view = new RemoteListView(repo, remotes, mode: 'push')
      view.confirmSelection()

      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['push', 'remote1'], options

  describe "when mode is push and there is no upstream set", ->
    it "calls git.cmd with ['push', '-u'] and remote name", ->
      spyOn(git, 'cmd').andCallFake ->
        if git.cmd.callCount is 1
          Promise.reject 'no upstream'
        else
          Promise.resolve 'pushing text'

      view = new RemoteListView(repo, remotes, mode: 'push')
      view.confirmSelection()

      waitsFor -> git.cmd.callCount > 1
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['push', '-u', 'remote1', 'HEAD'], options
