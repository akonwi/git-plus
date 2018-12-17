quibble = require 'quibble'
git = require '../../lib/git'
notifier = require '../../lib/notifier'
contextPackageFinder = require '../../lib/context-package-finder'
GitUnstageFileContext = require '../../lib/models/context/git-unstage-file-context'

{repo} = require '../fixtures'
selectedFilePath = 'selected/path'

describe "Context-menu commands", ->
  beforeEach ->
    spyOn(git, 'getRepoForPath').andReturn Promise.resolve(repo)

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
        waitsForPromise -> GitAddAndCommitContext()
        runs ->
          expect(git.add).toHaveBeenCalledWith repo, file: selectedFilePath
          expect(GitCommit).toHaveBeenCalledWith repo

    describe "when an object is not selected", ->
      it "notifies the user of the issue", ->
        spyOn(notifier, 'addInfo')
        GitAddAndCommitContext()
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
        waitsForPromise -> GitDiffContext()
        runs -> expect(GitDiff).toHaveBeenCalledWith repo, file: selectedFilePath

    describe "when an object is not selected", ->
      it "notifies the user of the issue", ->
        spyOn(notifier, 'addInfo')
        GitDiffContext()
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
        waitsForPromise -> GitDifftoolContext()
        runs -> expect(GitDiffTool).toHaveBeenCalledWith repo, file: selectedFilePath

    describe "when an object is not selected", ->
      it "notifies the user of the issue", ->
        spyOn(notifier, 'addInfo')
        GitDifftoolContext()
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
        spyOn(atom, 'confirm').andCallFake -> atom.confirm.mostRecentCall.args[0].buttons.Yes()
        waitsForPromise -> GitCheckoutFileContext()
        runs -> expect(GitCheckoutFile).toHaveBeenCalledWith repo, file: selectedFilePath

    describe "when an object is not selected", ->
      it "notifies the user of the issue", ->
        spyOn(notifier, 'addInfo')
        GitCheckoutFileContext()
        expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to checkout"

  describe "GitUnstageFileContext", ->
    describe "when an object in the tree is selected", ->
      it "calls git::cmd to unstage files", ->
        spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
        spyOn(git, 'cmd').andReturn Promise.resolve()
        waitsForPromise -> GitUnstageFileContext()
        runs -> expect(git.cmd).toHaveBeenCalledWith ['reset', 'HEAD', '--', selectedFilePath], cwd: repo.getWorkingDirectory()

    describe "when an object is not selected", ->
      it "notifies the user of the issue", ->
        spyOn(notifier, 'addInfo')
        GitUnstageFileContext()
        expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to unstage"

  describe "GitPullContext", ->
    [GitPull, GitPullContext] = []

    beforeEach ->
      GitPull = quibble '../../lib/models/git-pull', jasmine.createSpy('GitPull')
      GitPullContext = require '../../lib/models/context/git-pull-context'

    describe "when an object in the tree is selected", ->
      it "calls GitPull with the options received", ->
        spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
        waitsForPromise -> GitPullContext()
        runs -> expect(GitPull).toHaveBeenCalledWith repo

    describe "when an object is not selected", ->
      it "notifies the user of the issue", ->
        spyOn(notifier, 'addInfo')
        GitPullContext()
        expect(notifier.addInfo).toHaveBeenCalledWith "No repository found"

  describe "GitPushContext", ->
    [GitPush, GitPushContext] = []

    beforeEach ->
      GitPush = quibble '../../lib/models/git-push', jasmine.createSpy('GitPush')
      GitPushContext = require '../../lib/models/context/git-push-context'

    describe "when an object in the tree is selected", ->
      it "calls GitPush with the options received", ->
        spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
        waitsForPromise -> GitPushContext(setUpstream: true)
        runs -> expect(GitPush).toHaveBeenCalledWith repo, setUpstream: true

    describe "when an object is not selected", ->
      it "notifies the user of the issue", ->
        spyOn(notifier, 'addInfo')
        GitPushContext()
        expect(notifier.addInfo).toHaveBeenCalledWith "No repository found"

  describe "GitDiffBranchesContext", ->
    [GitDiffBranches, GitDiffBranchesContext] = []

    beforeEach ->
      GitDiffBranches = quibble '../../lib/models/git-diff-branches', jasmine.createSpy('GitDiffBranches')
      GitDiffBranchesContext = require '../../lib/models/context/git-diff-branches-context'

    describe "when an object in the tree is selected", ->
      it "calls GitDiffBranches", ->
        spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
        waitsForPromise -> GitDiffBranchesContext()
        runs -> expect(GitDiffBranches).toHaveBeenCalledWith repo

    describe "when an object is not selected", ->
      it "notifies the user of the issue", ->
        spyOn(notifier, 'addInfo')
        GitDiffBranchesContext()
        expect(notifier.addInfo).toHaveBeenCalledWith "No repository found"

  describe "GitDiffBranchFilesContext", ->
    [GitDiffBranchFiles, GitDiffBranchFilesContext] = []

    beforeEach ->
      GitDiffBranchFiles = quibble '../../lib/models/git-diff-branch-files', jasmine.createSpy('GitDiffBranchFiles')
      GitDiffBranchFilesContext = require '../../lib/models/context/git-diff-branch-files-context'

    describe "when an object in the tree is selected", ->
      it "calls GitDiffBranchFiles", ->
        spyOn(contextPackageFinder, 'get').andReturn {selectedPath: selectedFilePath}
        waitsForPromise -> GitDiffBranchFilesContext()
        runs -> expect(GitDiffBranchFiles).toHaveBeenCalledWith repo, selectedFilePath

    describe "when an object is not selected", ->
      it "notifies the user of the issue", ->
        spyOn(notifier, 'addInfo')
        GitDiffBranchFilesContext()
        expect(notifier.addInfo).toHaveBeenCalledWith "No repository found"
