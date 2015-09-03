git = require '../../lib/git'
notifier = require '../../lib/notifier'
{repo, pathToRepoFile} = require '../fixtures'
SelectStageFiles = require '../../lib/views/select-stage-files-view'

describe "SelectStageFiles", ->
  it "stages the selected files", ->
    spyOn(git, 'cmd').andReturn Promise.resolve ''
    fileItem =
      path: pathToRepoFile
    view = new SelectStageFiles(repo, [fileItem])
    view.confirmSelection()
    view.find('.btn-stage-button').click()
    expect(git.cmd).toHaveBeenCalledWith ['add', '-f', pathToRepoFile], cwd: repo.getWorkingDirectory()
