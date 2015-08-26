fs = require 'fs-plus'
Path = require 'flavored-path'

{repo, workspace, pathToRepoFile} = require '../fixtures'
git = require '../../lib/git'
GitCommit = require '../../lib/models/git-commit-beta'

mockGit = ->
  spyOn(git, 'cmd').andCallFake ->
    args = git.cmd.mostRecentCall.args[0]
    if args[2] is 'core.commentchar'
      Promise.resolve ''
    else if args[0] is 'status'
      Promise.resolve "M #{pathToRepoFile}"

  spyOn(git, 'stagedFiles').andCallFake ->
    args = git.stagedFiles.mostRecentCall.args
    if args[0].getWorkingDirectory() is repo.getWorkingDirectory()
      Promise.resolve [pathToRepoFile]

  spyOn(fs, 'writeFileSync')

mockAtom = ->
  spyOn(atom.workspace, 'getActivePane').andCallFake workspace.getActivePane
  spyOn(atom.workspace, 'open').andCallFake workspace.open
  spyOn(atom.workspace, 'getPanes').andCallFake workspace.getPanes

describe "GitCommit", ->
  describe "a regular commit", ->
    it "saves the current pane", ->
      commit = GitCommit(repo)
      expect(commit.currentPane).toBeDefined()

    describe "::start", ->
      it "gets the commentchar from configs", ->
        waitsForPromise ->
          mockGit()
          GitCommit(repo).start().then ->
            expect(git.cmd).toHaveBeenCalledWith ['config', '--get', 'core.commentchar']

    # describe "::dir", ->
    #   it "returns the working directory of repo", ->
    #     mockGit()
    #     mockAtom()
    #     commit = new GitCommit(repo)
    #     expect(commit.dir()).toEqual repo.getWorkingDirectory()
    #
    # describe "::filePath", ->
    #   it "returns #{Path.join repo.getPath(), 'COMMIT_EDITMSG'}", ->
    #     mockGit()
    #     mockAtom()
    #     commit = new GitCommit(repo)
    #     expect(commit.filePath()).toEqual Path.join repo.getPath(), 'COMMIT_EDITMSG'
