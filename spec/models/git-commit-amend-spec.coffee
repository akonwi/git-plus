Path = require 'path'
fs = require 'fs-plus'

git = require '../../lib/git'
GitCommitAmend = require '../../lib/models/git-commit-amend'
{
  repo,
  pathToRepoFile,
  textEditor,
  commitPane,
  currentPane
} = require '../fixtures'

commitFilePath = Path.join(repo.getPath(), 'COMMIT_EDITMSG')

describe "GitCommitAmend", ->
  beforeEach ->
    spyOn(atom.workspace, 'getActivePane').andReturn currentPane
    spyOn(atom.workspace, 'open').andReturn Promise.resolve textEditor
    spyOn(atom.workspace, 'getPanes').andReturn [currentPane, commitPane]
    spyOn(atom.workspace, 'paneForURI').andReturn commitPane
    spyOn(git, 'refresh')

    spyOn(commitPane, 'destroy').andCallThrough()
    spyOn(currentPane, 'activate')

    spyOn(fs, 'unlink')
    spyOn(fs, 'readFileSync').andReturn ''
    spyOn(git, 'stagedFiles').andCallFake ->
      args = git.stagedFiles.mostRecentCall.args
      if args[0].getWorkingDirectory() is repo.getWorkingDirectory()
        Promise.resolve [pathToRepoFile]

    spyOn(git, 'cmd').andCallFake ->
      args = git.cmd.mostRecentCall.args[0]
      switch args[0]
        when 'whatchanged' then Promise.resolve 'last commit'
        when 'status' then Promise.resolve 'current status'
        else Promise.resolve ''

  it "gets the previous commit message and changed files", ->
    expectedGitArgs = ['whatchanged', '-1', '--name-status', '--format=%B']
    GitCommitAmend repo
    expect(git.cmd).toHaveBeenCalledWith expectedGitArgs, cwd: repo.getWorkingDirectory()

  it "writes to the new commit file", ->
    spyOn(fs, 'writeFileSync')
    GitCommitAmend repo
    waitsFor ->
      fs.writeFileSync.callCount > 0
    runs ->
      actualPath = fs.writeFileSync.mostRecentCall.args[0]
      expect(actualPath).toEqual commitFilePath

  xit "shows the file", ->
    GitCommitAmend repo
    waitsFor ->
      atom.workspace.open.callCount > 0
    runs ->
      expect(atom.workspace.open).toHaveBeenCalled()

  xit "calls git.cmd with ['commit'...] on textEditor save", ->
    GitCommitAmend repo
    textEditor.save()
    expect(git.cmd).toHaveBeenCalledWith ['commit', '--amend', '--cleanup=strip', "--file=#{commitFilePath}"], cwd: repo.getWorkingDirectory()

  xit "closes the commit pane when commit is successful", ->
    GitCommitAmend repo
    textEditor.save()
    waitsFor -> commitPane.destroy.callCount > 0
    runs -> expect(commitPane.destroy).toHaveBeenCalled()

  xit "cancels the commit on textEditor destroy", ->
    GitCommitAmend repo
    textEditor.destroy()
    expect(currentPane.activate).toHaveBeenCalled()
    expect(fs.unlink).toHaveBeenCalledWith commitFilePath
