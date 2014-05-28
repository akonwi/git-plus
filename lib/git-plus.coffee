GitCommit = require './git-commit'
GitAdd = require './git-add'
GitBranch = require './git-branch'
GitPull = require './git-pull'
GitDiff = require './git-diff'
GitDiffAll = require './git-diff-all'
GitPush = require './git-push'
GitCheckoutCurrentFile = require './git-checkout-current-file'
GitAddAndCommit = require './git-add-and-commit'
GitCommitAmend = require './git-commit-amend'
GitAddAllAndCommit = require './git-add-all-and-commit'

module.exports =
  configDefaults:
    includeStagedDiff: true
    openInPane: true
    wordDiff: true

  activate: (state) ->
    atom.workspaceView.command "git-plus:commit", -> GitCommit()
    atom.workspaceView.command "git-plus:commit-amend", -> GitCommitAmend()
    atom.workspaceView.command "git-plus:add", -> GitAdd()
    atom.workspaceView.command "git-plus:checkout-current-file", -> GitCheckoutCurrentFile()
    atom.workspaceView.command "git-plus:diff", -> GitDiff()
    atom.workspaceView.command "git-plus:diff-all", -> GitDiffAll()
    atom.workspaceView.command "git-plus:add-all", -> GitAdd(true)
    atom.workspaceView.command "git-plus:checkout", -> GitBranch.gitBranches()
    atom.workspaceView.command "git-plus:new-branch", -> GitBranch.newBranch()
    atom.workspaceView.command "git-plus:pull", -> GitPull()
    atom.workspaceView.command "git-plus:push", -> GitPush()
    atom.workspaceView.command "git-plus:add-and-commit", -> GitAddAndCommit()
    atom.workspaceView.command "git-plus:add-all-and-commit", -> GitAddAllAndCommit()

  deactivate: ->

  serialize: ->
