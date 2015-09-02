git = require '../../lib/git'
{repo, pathToRepoFile} = require '../fixtures'
GitLog = require '../../lib/models/git-log'
LogListView = require '../../lib/views/log-list-view'

view = new LogListView
logFileURI = 'atom://git-plus:log'

describe "GitLog", ->
  beforeEach ->
    spyOn(atom.workspace, 'open').andReturn Promise.resolve view
    spyOn(atom.workspace, 'addOpener')
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn { getPath: -> pathToRepoFile }
    spyOn(view, 'branchLog')
    waitsForPromise -> GitLog repo

  it "adds a custom opener for the log file URI", ->
    expect(atom.workspace.addOpener).toHaveBeenCalled()

  it "opens the log file URI", ->
    expect(atom.workspace.open).toHaveBeenCalledWith logFileURI

  it "calls branchLog on the view", ->
    expect(view.branchLog).toHaveBeenCalledWith repo

  describe "when 'onlyCurrentFile' option is true", ->
    it "calls currentFileLog on the view", ->
      spyOn(view, 'currentFileLog')
      waitsForPromise -> GitLog repo, onlyCurrentFile: true
      runs ->
        expect(view.currentFileLog).toHaveBeenCalledWith repo, repo.relativize pathToRepoFile
