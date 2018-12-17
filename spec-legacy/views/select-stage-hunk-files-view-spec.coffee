fs = require 'fs-plus'
git = require '../../lib/git'
{repo, pathToRepoFile} = require '../fixtures'
SelectStageHunkFiles = require '../../lib/views/select-stage-hunk-file-view'
SelectStageHunks = require '../../lib/views/select-stage-hunks-view'

describe "SelectStageHunkFiles", ->
  it "gets the diff of the selected file", ->
    spyOn(git, 'diff').andReturn Promise.resolve ''
    fileItem =
      path: pathToRepoFile
    view = new SelectStageHunkFiles(repo, [fileItem])
    view.confirmSelection()
    expect(git.diff).toHaveBeenCalledWith repo, pathToRepoFile

describe "SelectStageHunks", ->
  it "stages the selected hunk", ->
    spyOn(git, 'cmd').andReturn Promise.resolve ''
    spyOn(fs, 'unlink')
    spyOn(fs, 'writeFile').andCallFake ->
      fs.writeFile.mostRecentCall.args[3]()
    hunk =
      match: -> [1, 'this is a diff', 'hunk']
    view = new SelectStageHunks(repo, ["patch_path hunk1", hunk])
    patch_path = repo.getWorkingDirectory() + '/GITPLUS_PATCH'
    view.confirmSelection()
    view.find('.btn-stage-button').click()
    expect(git.cmd).toHaveBeenCalledWith ['apply', '--cached', '--', patch_path], cwd: repo.getWorkingDirectory()
