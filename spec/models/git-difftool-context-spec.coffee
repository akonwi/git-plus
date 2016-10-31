Path = require 'path'
notifier = require '../../lib/notifier'
GitDifftoolContext = require '../../lib/models/git-difftool-context'

{repo} = require '../fixtures'
mockSelectedPath = require('../tree-view-mock').serialize().selectedPath
mockPackage =
  mainModulePath: Path.resolve __dirname, '../tree-view-mock'
  deactivate: () ->
badMockPackage =
  mainModulePath: Path.resolve __dirname, '../bad-tree-view-mock'
  deactivate: () ->
contextCommandMap = jasmine.createSpy('contextCommandMap')

describe "GitDifftoolContext", ->
  describe "Using TreeView package", ->
    beforeEach -> atom.packages.loadPackage('tree-view')

    describe "when an object in the tree is selected", ->
      it "calls contextCommandMap::map with 'DiffTool' and the filepath for the tree object", ->
        spyOn(atom.packages, 'getLoadedPackage').andReturn mockPackage
        GitDifftoolContext repo, contextCommandMap
        expect(contextCommandMap).toHaveBeenCalledWith 'difftool', repo: repo, file: mockSelectedPath

    describe "when an object is not selected", ->
      it "notifies the userof the issue", ->
        spyOn(atom.packages, 'getLoadedPackage').andReturn badMockPackage
        spyOn(notifier, 'addInfo')
        GitDifftoolContext repo, contextCommandMap
        expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to diff"

  describe "Using SublimeTabs package", ->
    beforeEach -> atom.packages.loadPackage('sublime-tabs')

    describe "when an object in the tree is selected", ->
      it "calls contextCommandMap::map with 'DiffTool' and the filepath for the tree object", ->
        spyOn(atom.packages, 'getLoadedPackage').andReturn mockPackage
        GitDifftoolContext repo, contextCommandMap
        expect(contextCommandMap).toHaveBeenCalledWith 'difftool', repo: repo, file: mockSelectedPath

    describe "when an object is not selected", ->
      it "notifies the user of the issue", ->
        spyOn(atom.packages, 'getLoadedPackage').andReturn badMockPackage
        spyOn(notifier, 'addInfo')
        GitDifftoolContext repo, contextCommandMap
        expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to diff"
