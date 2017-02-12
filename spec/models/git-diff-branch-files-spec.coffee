{repo} = require '../fixtures'
git = require '../../lib/git'
GitDiffBranchFiles = require '../../lib/models/git-diff-branch-files'
DiffBranchFileChooser = require '../../lib/views/diff-branch-file-chooser'

describe "GitDiffBranchFiles", ->
  beforeEach ->
    spyOn(git, 'cmd').andReturn Promise.resolve 'foobar'

  it "gets the branches", ->
    GitDiffBranchFiles(repo)
    expect(git.cmd).toHaveBeenCalledWith ['branch', '--no-color'], cwd: repo.getWorkingDirectory()

  it "creates a DiffBranchFileChooser", ->
    GitDiffBranchFiles(repo).then (view) ->
      expect(view instanceof DiffBranchFileChooser).toBe true
