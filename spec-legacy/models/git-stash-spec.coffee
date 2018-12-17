{repo} = require '../fixtures'
git = require '../../lib/git'
GitStashApply = require '../../lib/models/git-stash-apply'
GitStashSave = require '../../lib/models/git-stash-save'
GitStashPop = require '../../lib/models/git-stash-pop'
GitStashDrop = require '../../lib/models/git-stash-drop'

options =
  cwd: repo.getWorkingDirectory()
colorOptions =
  color: true

describe "Git Stash commands", ->
  describe "Apply", ->
    it "calls git.cmd with 'stash' and 'apply'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve true
      GitStashApply(repo)
      expect(git.cmd).toHaveBeenCalledWith ['stash', 'apply'], options, colorOptions

  describe "Save", ->
    it "calls git.cmd with 'stash' and 'save'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve true
      GitStashSave(repo)
      expect(git.cmd).toHaveBeenCalledWith ['stash', 'save'], options, colorOptions

  describe "Save with message", ->
    it "calls git.cmd with 'stash', 'save', and provides message", ->
      message = 'foobar'
      spyOn(git, 'cmd').andReturn Promise.resolve true
      GitStashSave(repo, {message})
      expect(git.cmd).toHaveBeenCalledWith ['stash', 'save', message], options, colorOptions

  describe "Pop", ->
    it "calls git.cmd with 'stash' and 'pop'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve true
      GitStashPop(repo)
      expect(git.cmd).toHaveBeenCalledWith ['stash', 'pop'], options, colorOptions

  describe "Drop", ->
    it "calls git.cmd with 'stash' and 'drop'", ->
      spyOn(git, 'cmd').andReturn Promise.resolve true
      GitStashDrop(repo)
      expect(git.cmd).toHaveBeenCalledWith ['stash', 'drop'], options, colorOptions
