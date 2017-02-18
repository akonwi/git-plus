git = require '../../lib/git'
RemoteListView = require '../../lib/views/remote-list-view'
{repo} = require '../fixtures'
options = {cwd: repo.getWorkingDirectory()}
colorOptions = {color: true}
remotes = "remote1\nremote2"
pullBeforePush = 'git-plus.remoteInteractions.pullBeforePush'
pullRebase = 'git-plus.remoteInteractions.pullRebase'
promptForBranch = 'git-plus.remoteInteractions.promptForBranch'

describe "RemoteListView", ->
  it "displays a list of remotes", ->
    view = new RemoteListView(repo, remotes, mode: 'pull')
    expect(view.items.length).toBe 2

  describe "when mode is pull", ->
    describe "when promptForBranch is enabled", ->
      it "it calls git.cmd to get the remote branches", ->
        atom.config.set(promptForBranch, true)
        view = new RemoteListView(repo, remotes, mode: 'pull')
        spyOn(git, 'cmd').andCallFake ->
          Promise.resolve 'branch1\nbranch2'

        view.confirmSelection()
        waitsFor -> git.cmd.callCount > 0
        runs ->
          expect(git.cmd).toHaveBeenCalledWith ['branch', '--no-color', '-r'], options

    describe "when promptForBranch is disabled", ->
      it "it calls the _pull function", ->
        atom.config.set(promptForBranch, false)
        view = new RemoteListView(repo, remotes, mode: 'pull')
        spyOn(git, 'cmd').andCallFake ->
          Promise.resolve 'branch1\nbranch2'

        view.confirmSelection()
        waitsFor -> git.cmd.callCount > 0
        runs ->
          expect(git.cmd).toHaveBeenCalledWith ['pull', 'origin', 'foo'], options, colorOptions

  describe "when mode is fetch", ->
    it "it calls git.cmd to with ['fetch'] and the remote name", ->
      spyOn(git, 'cmd').andCallFake ->
        Promise.resolve 'fetched stuff'

      view = new RemoteListView(repo, remotes, mode: 'fetch')
      view.confirmSelection()
      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['fetch', 'remote1'], options, colorOptions

  describe "when mode is fetch-prune", ->
    it "it calls git.cmd to with ['fetch', '--prune'] and the remote name", ->
      spyOn(git, 'cmd').andCallFake ->
        Promise.resolve 'fetched stuff'

      view = new RemoteListView(repo, remotes, mode: 'fetch-prune')
      view.confirmSelection()
      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['fetch', '--prune', 'remote1'], options, colorOptions

  describe "when mode is push", ->
    it "calls git.cmd with ['push']", ->
      spyOn(git, 'cmd').andReturn Promise.resolve 'pushing text'

      view = new RemoteListView(repo, remotes, mode: 'push')
      view.confirmSelection()

      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['push', 'remote1'], options, colorOptions

  describe "when mode is 'push -u'", ->
    it "calls git.cmd with ['push', '-u'] and remote name", ->
      spyOn(git, 'cmd').andReturn Promise.resolve('pushing text')
      view = new RemoteListView(repo, remotes, mode: 'push -u')
      view.confirmSelection()

      waitsFor -> git.cmd.callCount > 0
      runs ->
        expect(git.cmd).toHaveBeenCalledWith ['push', '-u', 'remote1', 'HEAD'], options, colorOptions

  describe "when the the config for pull before push is set to true", ->
    describe "when promptForBranch is disabled", ->
      it "calls git.cmd with ['pull'], remote name, and branch name and then with ['push']", ->
        spyOn(git, 'cmd').andReturn Promise.resolve 'branch1'
        atom.config.set(pullBeforePush, true)

        view = new RemoteListView(repo, remotes, mode: 'push')
        view.confirmSelection()

        waitsFor -> git.cmd.callCount > 1
        runs ->
          expect(git.cmd).toHaveBeenCalledWith ['pull', 'origin', 'foo'], options, colorOptions
          expect(git.cmd).toHaveBeenCalledWith ['push', 'remote1'], options, colorOptions

    describe "when promptForBranch is enabled", ->
      it "calls git.cmd with ['branch', '--no-color', '-r']", ->
        spyOn(git, 'cmd').andReturn Promise.resolve 'remote/branch1'
        atom.config.set(pullBeforePush, true)
        atom.config.set(promptForBranch, true)

        view = new RemoteListView(repo, remotes, mode: 'push')
        view.confirmSelection()

        waitsFor -> git.cmd.callCount > 0
        runs ->
          expect(git.cmd).toHaveBeenCalledWith ['branch', '--no-color', '-r'], options

    describe "when the the config for pullRebase is set to true", ->
      it "calls git.cmd with ['pull', '--rebase'], remote name, and branch name and then with ['push']", ->
        spyOn(git, 'cmd').andReturn Promise.resolve 'branch1'
        atom.config.set(pullBeforePush, true)
        atom.config.set(pullRebase, true)
        atom.config.set(promptForBranch, false)

        view = new RemoteListView(repo, remotes, mode: 'push')
        view.confirmSelection()

        waitsFor -> git.cmd.callCount > 1
        runs ->
          expect(git.cmd).toHaveBeenCalledWith ['pull', '--rebase', 'origin', 'foo'], options, colorOptions
          expect(git.cmd).toHaveBeenCalledWith ['push', 'remote1'], options, colorOptions
