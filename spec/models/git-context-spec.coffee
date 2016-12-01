git = require '../../lib/git'
notifier = require '../../lib/notifier'
contextPackageFinder = require '../../lib/context-package-finder'
GitAddContext = require '../../lib/models/context/git-add-context'
GitAddAndCommitContext = require '../../lib/models/context/git-add-and-commit-context'
GitCheckoutFileContext = require '../../lib/models/context/git-checkout-file-context'
GitDiffContext = require '../../lib/models/context/git-diff-context'
GitDifftoolContext = require '../../lib/models/context/git-difftool-context'
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
  describe "when an object in the tree is selected", ->
    it "calls git::add and GitCommit", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
      spyOn(git, 'add').andReturn Promise.resolve()
      GitAddAndCommitContext repo
      expect(git.add).toHaveBeenCalledWith repo, file: selectedFilePath
      # TODO: figure out how to validate GitCommit was called
      # expect(GitCommit).toHaveBeenCalledWith repo

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitAddAndCommitContext repo
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to add and commit"

describe "GitDiffContext", ->
  xdescribe "when an object in the tree is selected", ->
    it "calls GitDiff", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
      GitDiffContext repo
      # TODO: expect(GitDiff).toHaveBeenCalledWith repo, file: selectedFilePath

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitDiffContext repo
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to diff"

describe "GitDifftoolContext", ->
  xdescribe "when an object in the tree is selected", ->
    it "calls GitDiffTool", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
      GitDifftoolContext repo
      # expect(GitDiffTool).toHaveBeenCalledWith repo, file: selectedFilePath

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitDifftoolContext repo
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to diff"

describe "GitCheckoutFileContext", ->
  xdescribe "when an object in the tree is selected", ->
    it "calls CheckoutFile", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
      GitCheckoutFileContext repo
      # expect(GitCheckoutFile).toHaveBeenCalledWith repo, file: selectedFilePath

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
