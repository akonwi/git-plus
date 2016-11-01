notifier = require '../../lib/notifier'
contextPackageFinder = require '../../lib/context-package-finder'
GitAddContext = require '../../lib/models/git-add-context'

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
    it "notifies the userof the issue", ->
      spyOn(notifier, 'addInfo')
      GitAddContext repo, contextCommandMap
      expect(notifier.addInfo).toHaveBeenCalledWith "No file selected to add"
