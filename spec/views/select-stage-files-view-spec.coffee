git = require '../../lib/git'
{repo, pathToRepoFile} = require '../fixtures'
SelectStageFiles = require '../../lib/views/select-stage-files-view'
SelectUnStageFiles = require '../../lib/views/select-unstage-files-view'

describe "SelectStageFiles", ->
  it "stages the selected files", ->
    spyOn(git, 'cmd').andReturn Promise.resolve ''
    fileItem =
      path: pathToRepoFile
    view = new SelectStageFiles(repo, [fileItem])
    view.confirmSelection()
    view.find('.btn-stage-button').click()
    expect(git.cmd).toHaveBeenCalledWith ['add', '-f', pathToRepoFile], cwd: repo.getWorkingDirectory()

describe "SelectUnStageFiles", ->
  it "unstages the selected files", ->
    spyOn(git, 'cmd').andReturn Promise.resolve ''
    fileItem =
      path: pathToRepoFile
    view = new SelectUnStageFiles(repo, [fileItem])
    view.confirmSelection()
    view.find('.btn-unstage-button').click()
    expect(git.cmd).toHaveBeenCalledWith ['reset', 'HEAD', '--', pathToRepoFile], cwd: repo.getWorkingDirectory()
