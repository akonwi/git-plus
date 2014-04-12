GitCommit = require './git-commit'
GitWrite = require './git-write'
GitBranch = require './git-branch'

module.exports =
  activate: (state) ->
    atom.workspaceView.command "git-plus:commit", -> GitCommit()
    atom.workspaceView.command "git-plus:write", -> GitWrite()
    atom.workspaceView.command "git-plus:write-all", -> GitWrite(true)
    atom.workspaceView.command "git-plus:change-branch", -> GitBranch.gitBranches()
    atom.workspaceView.command "git-plus:new-branch", -> GitBranch.newBranch()

  deactivate: ->

  serialize: ->
