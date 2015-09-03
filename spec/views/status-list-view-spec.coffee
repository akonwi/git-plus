fs = require 'fs-plus'
git = require '../../lib/git'
{repo} = require '../fixtures'
StatusListView = require '../../lib/views/status-list-view'

describe "StatusListView", ->
  describe "when there are modified files", ->
    it "displays a list of modified files", ->
      view = new StatusListView(repo, [" M\tfile.txt", " D\tanother.txt", ''])
      expect(view.items.length).toBe 2

    it "calls git.cmd with 'diff' when user doesn't want to open the file", ->
      spyOn(window, 'confirm').andReturn false
      spyOn(git, 'cmd').andReturn Promise.resolve 'foobar'
      spyOn(fs, 'stat').andCallFake ->
        stat = isDirectory: -> false
        fs.stat.mostRecentCall.args[1](null, stat)
      view = new StatusListView(repo, [" M\tfile.txt", " D\tanother.txt", ''])
      view.confirmSelection()
      expect('diff' in git.cmd.mostRecentCall.args[0]).toBe true


  describe "when there are unstaged files", ->
    beforeEach ->
      spyOn(window, 'confirm').andReturn true

    it "opens the file when it is a file", ->
      spyOn(atom.workspace, 'open')
      spyOn(fs, 'stat').andCallFake ->
        stat = isDirectory: -> false
        fs.stat.mostRecentCall.args[1](null, stat)
      view = new StatusListView(repo, [" M\tfile.txt", " D\tanother.txt", ''])
      view.confirmSelection()
      expect(atom.workspace.open).toHaveBeenCalled()

    it "opens the directory in a project when it is a directory", ->
      spyOn(atom, 'open')
      spyOn(fs, 'stat').andCallFake ->
        stat = isDirectory: -> true
        fs.stat.mostRecentCall.args[1](null, stat)
      view = new StatusListView(repo, [" M\tfile.txt", " D\tanother.txt", ''])
      view.confirmSelection()
      expect(atom.open).toHaveBeenCalled()
  # describe "when there are unstaged files", ->
  #   it "checkouts the selected branch", ->
  #     @view.confirmSelection()
  #     @view.checkout 'branch1'
  #     waitsFor -> git.cmd.callCount > 0
  #     expect(git.cmd).toHaveBeenCalledWith ['checkout', 'branch1'], cwd: repo.getWorkingDirectory()
