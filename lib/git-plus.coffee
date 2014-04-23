GitCommit = require './git-commit'
GitWrite = require './git-write'
GitBranch = require './git-branch'
GitPull = require './git-pull'
GitPush = require './git-push'

module.exports =
  activate: (state) ->
    atom.workspaceView.command "git-plus:commit", -> GitCommit()
    atom.workspaceView.command "git-plus:write", -> GitWrite()
    atom.workspaceView.command "git-plus:write-all", -> GitWrite(true)
    atom.workspaceView.command "git-plus:change-branch", -> GitBranch.gitBranches()
    atom.workspaceView.command "git-plus:new-branch", -> GitBranch.newBranch()
    atom.workspaceView.command "git-plus:pull", -> GitPull()
    atom.workspaceView.command "git-plus:push", -> GitPush()

  deactivate: ->

  serialize: ->
