{repo} = require '../fixtures'
git = require '../../lib/git'
GitStashApply = require '../../lib/models/git-stash-apply'
GitStashSave = require '../../lib/models/git-stash-save'
GitStashPop = require '../../lib/models/git-stash-pop'
GitStashDrop = require '../../lib/models/git-stash-drop'

options =
  cwd: repo.getWorkingDirectory()

describe "Git Stash commands", ->
  describe "Apply", ->
    it "calls git.cmd with 'stash' and 'apply'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve true
      GitStashApply(repo)
      expect(git.cmd).toHaveBeenCalledWith ['stash', 'apply'], options

  describe "Save", ->
    it "calls git.cmd with 'stash' and 'save'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve true
      GitStashSave(repo)
      expect(git.cmd).toHaveBeenCalledWith ['stash', 'save'], options

  describe "Pop", ->
    it "calls git.cmd with 'stash' and 'pop'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve true
      GitStashPop(repo)
      expect(git.cmd).toHaveBeenCalledWith ['stash', 'pop'], options

  describe "Drop", ->
    it "calls git.cmd with 'stash' and 'drop'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve true
      GitStashDrop(repo)
      expect(git.cmd).toHaveBeenCalledWith ['stash', 'drop'], options
