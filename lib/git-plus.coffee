GitCommit = require './git-commit'
GitWrite = require './git-write'
GitBranches = require './git-branch'

module.exports =
  activate: (state) ->
    atom.workspaceView.command "git-plus:commit", -> GitCommit()
    atom.workspaceView.command "git-plus:write", -> GitWrite()
    atom.workspaceView.command "git-plus:write-all", -> GitWrite(true)
    atom.workspaceView.command "git-plus:change-branch", -> GitBranches()

  deactivate: ->

  serialize: ->
