fs = require 'fs-plus'
Path = require 'flavored-path'

{repo, workspace, pathToRepoFile} = require '../fixtures'
git = require '../../lib/git'
GitCommit = require '../../lib/models/git-commit-beta'

# status = jasmine.createSpyObj('status', ['replace', 'trim'])
status =
  replace: -> status
  trim: -> status

mockGit = ->
  spyOn(status, 'replace').andCallFake -> status
  spyOn(status, 'trim').andCallThrough()

  spyOn(fs, 'writeFileSync')
  spyOn(git, 'cmd').andCallFake ->
    args = git.cmd.mostRecentCall.args[0]
    if args[0] is 'config'
      Promise.resolve ''
    else if args[0] is 'status'
      Promise.resolve status

  spyOn(git, 'stagedFiles').andCallFake ->
    args = git.stagedFiles.mostRecentCall.args
    if args[0].getWorkingDirectory() is repo.getWorkingDirectory()
      Promise.resolve [pathToRepoFile]

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

      it "gets staged files", ->
        waitsForPromise ->
          mockGit()
          GitCommit(repo).start().then ->
            expect(git.cmd).toHaveBeenCalledWith ['status'], cwd: repo.getWorkingDirectory()

      it "removes lines with '(...)' from status", ->
        waitsForPromise ->
          mockGit()
          GitCommit(repo).start().then ->
            expect(status.replace).toHaveBeenCalled()

      it "gets the commit template from git configs", ->
        waitsForPromise ->
          mockGit()
          GitCommit(repo).start().then ->
            expect(git.cmd).toHaveBeenCalledWith ['config', '--get', 'commit.template']

      it "writes to a file and the commentchar is default '#'", ->
        waitsForPromise ->
          mockGit()
          GitCommit(repo).start().then ->
            argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
            expect(argsTo_fsWriteFile[0]).toEqual Path.join(repo.getPath(), 'COMMIT_EDITMSG')
            expect(argsTo_fsWriteFile[1].charAt(0)).toBe '#'
