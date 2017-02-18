quibble = require 'quibble'
git = require '../../lib/git'
{repo} = require '../fixtures'

describe "GitStageFilesBeta", ->
  it "calls git.unstagedFiles and git.stagedFiles", ->
    SelectView = quibble '../../lib/views/select-stage-files-view-beta', jasmine.createSpy('SelectView')
    GitStageFiles = require '../../lib/models/git-stage-files-beta'

    unstagedFile = path: 'unstaged.file', status: 'M', staged: false
    stagedFile = path: 'staged.file', status: 'M', staged: true

    spyOn(git, 'unstagedFiles').andReturn Promise.resolve([unstagedFile])
    spyOn(git, 'stagedFiles').andReturn Promise.resolve([stagedFile])
    waitsForPromise -> GitStageFiles repo
    runs ->
      expect(git.unstagedFiles).toHaveBeenCalled()
      expect(git.stagedFiles).toHaveBeenCalled()
      expect(SelectView).toHaveBeenCalledWith repo, [unstagedFile, stagedFile]
