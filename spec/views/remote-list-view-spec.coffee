git = require '../../lib/git'
RemoteListView = require '../../lib/views/remote-list-view'
{repo} = require '../fixtures'
options = {cwd: repo.getWorkingDirectory()}
remotes = "remote1\nremote2"
pullBeforePush = 'git-plus.pullBeforePush'

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
      spyOn(git, 'cmd').andReturn Promise.resolve 'pushing text'

      view = new RemoteListView(repo, remotes, mode: 'push')
      view.confirmSelection()

      waitsFor -> git.cmd.callCount > 1
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['push', 'remote1'], options

  describe "when mode is push and there is no upstream set", ->
    it "calls git.cmd with ['push', '-u'] and remote name", ->
      atom.config.set(pullBeforePush, 'no')
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

    describe "when the the config for pull before push is set to true", ->
      it "calls git.cmd with ['pull'], remote name, and branch name and then with ['push']", ->
        spyOn(git, 'cmd').andReturn Promise.resolve 'branch1'
        atom.config.set(pullBeforePush, 'pull')

        view = new RemoteListView(repo, remotes, mode: 'push')
        view.confirmSelection()

        waitsFor -> git.cmd.callCount > 2
        runs ->
          expect(git.cmd).toHaveBeenCalledWith ['pull', 'remote1', 'branch1'], options
          expect(git.cmd).toHaveBeenCalledWith ['push', 'remote1'], options

    describe "when the the config for pull before push is set to 'Pull --rebase'", ->
      it "calls git.cmd with ['pull', '--rebase'], remote name, and branch name and then with ['push']", ->
        spyOn(git, 'cmd').andReturn Promise.resolve 'branch1'
        atom.config.set(pullBeforePush, 'pull --rebase')

        view = new RemoteListView(repo, remotes, mode: 'push')
        view.confirmSelection()

        waitsFor -> git.cmd.callCount > 2
        runs ->
          expect(git.cmd).toHaveBeenCalledWith ['pull', '--rebase', 'remote1', 'branch1'], options
          expect(git.cmd).toHaveBeenCalledWith ['push', 'remote1'], options
