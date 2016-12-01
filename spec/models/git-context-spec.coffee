quibble = require 'quibble'
git = require '../../lib/git'
notifier = require '../../lib/notifier'
contextPackageFinder = require '../../lib/context-package-finder'
GitAddContext = require '../../lib/models/context/git-add-context'
GitUnstageFileContext = require '../../lib/models/context/git-unstage-file-context'

{repo} = require '../fixtures'
selectedFilePath = 'selected/path'

describe "GitAddContext", ->
  describe "when an object in the tree is selected", ->
    it "calls git::add", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
      spyOn(git, 'add')
      GitAddContext repo
      expect(git.add).toHaveBeenCalledWith repo, file: selectedFilePath

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitAddContext repo
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to add"

describe "GitAddAndCommitContext", ->
  GitAddAndCommitContext = null
  GitCommit = null

  beforeEach ->
    GitCommit = quibble '../../lib/models/git-commit', jasmine.createSpy('GitCommit')
    GitAddAndCommitContext = require '../../lib/models/context/git-add-and-commit-context'

  describe "when an object in the tree is selected", ->
    it "calls git::add and GitCommit", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
      spyOn(git, 'add').andReturn Promise.resolve()
      waitsForPromise -> GitAddAndCommitContext repo
      runs ->
        expect(git.add).toHaveBeenCalledWith repo, file: selectedFilePath
        expect(GitCommit).toHaveBeenCalledWith repo

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitAddAndCommitContext repo
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to add and commit"

describe "GitDiffContext", ->
  GitDiff = null
  GitDiffContext = null

  beforeEach ->
    GitDiff = quibble '../../lib/models/git-diff', jasmine.createSpy('GitDiff')
    GitDiffContext = require '../../lib/models/context/git-diff-context'

  describe "when an object in the tree is selected", ->
    it "calls GitDiff", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
      GitDiffContext repo
      expect(GitDiff).toHaveBeenCalledWith repo, file: selectedFilePath

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitDiffContext repo
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to diff"

describe "GitDifftoolContext", ->
  GitDiffTool = null
  GitDifftoolContext = null

  beforeEach ->
    GitDiffTool = quibble '../../lib/models/git-difftool', jasmine.createSpy('GitDiffTool')
    GitDifftoolContext = require '../../lib/models/context/git-difftool-context'

  describe "when an object in the tree is selected", ->
    it "calls GitDiffTool", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
      GitDifftoolContext repo
      expect(GitDiffTool).toHaveBeenCalledWith repo, file: selectedFilePath

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitDifftoolContext repo
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to diff"

describe "GitCheckoutFileContext", ->
  GitCheckoutFile = null
  GitCheckoutFileContext = null

  beforeEach ->
    GitCheckoutFile = quibble '../../lib/models/git-checkout-file', jasmine.createSpy('GitCheckoutFile')
    GitCheckoutFileContext = require '../../lib/models/context/git-checkout-file-context'

  describe "when an object in the tree is selected", ->
    it "calls CheckoutFile", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
      GitCheckoutFileContext repo
      expect(GitCheckoutFile).toHaveBeenCalledWith repo, file: selectedFilePath

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitCheckoutFileContext repo
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to checkout"

describe "GitUnstageFileContext", ->
  describe "when an object in the tree is selected", ->
    it "calls git::cmd to unstage files", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
      spyOn(git, 'cmd').andReturn Promise.resolve()
      GitUnstageFileContext repo
      expect(git.cmd).toHaveBeenCalledWith ['reset', 'HEAD', '--', selectedFilePath], cwd: repo.getWorkingDirectory()

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitUnstageFileContext repo
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to unstage"
