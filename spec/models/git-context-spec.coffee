notifier = require '../../lib/notifier'
contextPackageFinder = require '../../lib/context-package-finder'
GitAddContext = require '../../lib/models/git-add-context'
GitAddAndCommitContext = require '../../lib/models/git-add-and-commit-context'
GitCheckoutFileContext = require '../../lib/models/git-checkout-file-context'
GitDiffContext = require '../../lib/models/git-diff-context'

{repo} = require '../fixtures'
mockSelectedPath = 'selected/path'
contextCommandMap = jasmine.createSpy('contextCommandMap')

describe "GitAddContext", ->
  describe "when an object in the tree is selected", ->
    it "calls contextCommandMap::map with 'add' and the filepath for the tree object", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: mockSelectedPath}
      GitAddContext repo, contextCommandMap
      expect(contextCommandMap).toHaveBeenCalledWith 'add', repo: repo, file: mockSelectedPath

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitAddContext repo, contextCommandMap
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to add"

describe "GitAddAndCommitContext", ->
  describe "when an object in the tree is selected", ->
    it "calls contextCommandMap::map with 'add-and-commit' and the filepath for the tree object", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: mockSelectedPath}
      GitAddAndCommitContext repo, contextCommandMap
      expect(contextCommandMap).toHaveBeenCalledWith 'add-and-commit', repo: repo, file: mockSelectedPath

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitAddAndCommitContext repo, contextCommandMap
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to add and commit"

describe "GitDiffContext", ->
  describe "when an object in the tree is selected", ->
    it "calls contextCommandMap::map with 'diff' and the filepath for the tree object", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: mockSelectedPath}
      GitDiffContext repo, contextCommandMap
      expect(contextCommandMap).toHaveBeenCalledWith 'diff', repo: repo, file: mockSelectedPath

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitDiffContext repo, contextCommandMap
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to diff"

describe "GitCheckoutFileContext", ->
  describe "when an object in the tree is selected", ->
    it "calls contextCommandMap::map with 'checkout' and the filepath for the tree object", ->
      spyOn(contextPackageFinder, 'get').andReturn {selectedPath: mockSelectedPath}
      GitCheckoutFileContext repo, contextCommandMap
      expect(contextCommandMap).toHaveBeenCalledWith 'checkout-file', repo: repo, file: mockSelectedPath

  describe "when an object is not selected", ->
    it "notifies the user of the issue", ->
      spyOn(notifier, 'addInfo')
      GitCheckoutFileContext repo, contextCommandMap
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to checkout"
