fs = require 'fs-plus'
Path = require 'flavored-path'

git = require '../../lib/git'
GitCommitAmend = require '../../lib/models/git-commit-amend'
{
  repo,
  pathToRepoFile
} = require '../fixtures'
lastCommitMessage = "commit message"
lastCommitStatus = "M   some-file.txt"
lastCommit =
  """#{lastCommitMessage}

  #{lastCommitStatus}
  """
currentStatus =
  """deleted:   some-file.txt
  modified: another-file.txt"""

describe "GitCommitAmend", ->
  beforeEach ->
    spyOn(fs, 'readFileSync').andReturn ''
    spyOn(git, 'stagedFiles').andCallFake ->
      args = git.stagedFiles.mostRecentCall.args
      if args[0].getWorkingDirectory() is repo.getWorkingDirectory()
        Promise.resolve [pathToRepoFile]

    spyOn(git, 'cmd').andCallFake ->
      args = git.cmd.mostRecentCall.args[0]
      switch args[0]
        when 'whatchanged' then Promise.resolve lastCommit
        when 'config' then Promise.resolve ''
        when 'status' then Promise.resolve currentStatus
        else Promise.resolve ''

  it "gets the previous commit message and changed files", ->
    expectedGitArgs = ['whatchanged', '-1', '--name-status', '--format=%B']
    GitCommitAmend repo
    expect(git.cmd).toHaveBeenCalledWith expectedGitArgs, cwd: repo.getWorkingDirectory()

  it "prepares the new commit file", ->
    spyOn(fs, 'writeFileSync')
    commitFilePath = Path.join(repo.getPath(), 'COMMIT_EDITMSG')
    expectedOutput =
      """#{lastCommitMessage}
      # Please enter the commit message for your changes. Lines starting
      # with '#' will be ignored, and an empty message aborts the commit.
      #
      # #{currentStatus}"""
    waitsForPromise ->
      GitCommitAmend repo
    runs ->
      expect(fs.writeFileSync).toHaveBeenCalledWith commitFilePath, expectedOutput
