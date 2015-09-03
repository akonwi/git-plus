git = require '../../lib/git'
{repo, pathToRepoFile} = require '../fixtures'
SelectStageHunkFiles = require '../../lib/views/select-stage-hunk-file-view'
# SelectUnStageFiles = require '../../lib/views/select-unstage-files-view'

describe "SelectStageHunkFiles", ->
  it "gets the diff of the selected file", ->
    spyOn(git, 'diff').andReturn Promise.resolve ''
    fileItem =
      path: pathToRepoFile
    view = new SelectStageHunkFiles(repo, [fileItem])
    view.confirmSelection()
    expect(git.diff).toHaveBeenCalledWith repo, pathToRepoFile

# describe "SelectUnStageFiles", ->
#   it "unstages the selected files", ->
#     spyOn(git, 'cmd').andReturn Promise.resolve ''
#     fileItem =
#       path: pathToRepoFile
#     view = new SelectUnStageFiles(repo, [fileItem])
#     view.confirmSelection()
#     view.find('.btn-unstage-button').click()
#     expect(git.cmd).toHaveBeenCalledWith ['reset', 'HEAD', '--', pathToRepoFile], cwd: repo.getWorkingDirectory()
