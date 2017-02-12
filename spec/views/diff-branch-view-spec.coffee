{repo, pathToRepoFile, textEditor} = require '../fixtures'
git = require '../../lib/git'
DiffBranchView = require '../../lib/views/diff-branch-view'

describe "GitBranchView", ->
  beforeEach ->
    @branchView = new DiffBranchView(repo, "branch1\nbranch2")
    spyOn(atom.workspace, 'open')
    spyOn(git, 'cmd').andReturn Promise.resolve 'foobar'

  it "gets the git diff and opens the file", ->
    @branchView.confirmSelection()
    waitsFor -> git.cmd.callCount > 1
    runs ->
      expect(git.cmd).toHaveBeenCalledWith ['diff', '--stat', repo.branch, 'branch1'], {cwd: repo.getWorkingDirectory()}
      expect(atom.workspace.open).toHaveBeenCalledWith(repo.getPath() + '/atom_git_plus.diff')
