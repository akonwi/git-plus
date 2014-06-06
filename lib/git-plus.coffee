GitCommit = require './models/git-commit'
GitAdd = require './models/git-add'
GitBranch = require './models/git-branch'
GitPull = require './models/git-pull'
GitDiff = require './models/git-diff'
GitDiffAll = require './models/git-diff-all'
GitPush = require './models/git-push'
GitFetch = require './models/git-fetch'
GitCheckoutCurrentFile = require './models/git-checkout-current-file'
GitAddAndCommit = require './models/git-add-and-commit'
GitCommitAmend = require './models/git-commit-amend'
GitAddAllAndCommit = require './models/git-add-all-and-commit'
GitRemove = require './models/git-remove'
GitLog = require './models/git-log'
GitShow = require './models/git-show'
GitTags = require './models/git-tags'

module.exports =
  configDefaults:
    includeStagedDiff: true
    openInPane: true
    wordDiff: true
    amountOfCommitsToShow: 25

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
    atom.workspaceView.command "git-plus:fetch", -> GitFetch()
    atom.workspaceView.command "git-plus:add-and-commit", -> GitAddAndCommit()
    atom.workspaceView.command "git-plus:add-all-and-commit", -> GitAddAllAndCommit()
    atom.workspaceView.command "git-plus:remove", -> GitRemove(true)
    atom.workspaceView.command "git-plus:remove-current-file", -> GitRemove()
    atom.workspaceView.command "git-plus:log", -> GitLog()
    atom.workspaceView.command "git-plus:log-current-file", -> GitLog(true)
    atom.workspaceView.command "git-plus:show", -> GitShow()
    atom.workspaceView.command "git-plus:tags", -> GitTags()

  deactivate: ->

  serialize: ->
