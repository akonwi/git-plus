git = require '../../lib/git'
SelectStageFiles = require '../../lib/views/select-stage-files-view'

{repo, pathToRepoFile} = require '../fixtures'
stagedFile =
  staged: true
  path: pathToRepoFile + '1'
unstagedFile =
  staged: false
  path: pathToRepoFile

describe "SelectStageFiles", ->
  it "renders staged files with the css class 'active'", ->
    spyOn(git, 'cmd').andReturn Promise.resolve ''
    view = new SelectStageFiles(repo, [stagedFile, unstagedFile])
    expect(view.find('li.active').length).toBe 1

  it "toggles staged files and their css class of 'active'", ->
    spyOn(git, 'cmd').andReturn Promise.resolve ''
    view = new SelectStageFiles(repo, [stagedFile, unstagedFile])
    expect(view.find('li.active').length).toBe 1
    selectedItem = view.getSelectedItem()
    while not selectedItem.staged
      selectedItem = view.selectNextItemView()
    view.confirmed(selectedItem, view.getSelectedItemView())
    expect(view.find('li.active').length).toBe 0

  it "stages the selected files", ->
    spyOn(git, 'cmd').andReturn Promise.resolve ''
    view = new SelectStageFiles(repo, [unstagedFile])
    view.confirmSelection()
    view.find('.btn-apply-button').click()
    expect(git.cmd).toHaveBeenCalledWith ['add', '-f', unstagedFile.path], cwd: repo.getWorkingDirectory()

  it "unstages the selected files", ->
    spyOn(git, 'cmd').andReturn Promise.resolve ''
    view = new SelectStageFiles(repo, [stagedFile])
    view.find('.btn-apply-button').click()
    expect(git.cmd).toHaveBeenCalledWith ['reset', 'HEAD', '--', stagedFile.path], cwd: repo.getWorkingDirectory()
