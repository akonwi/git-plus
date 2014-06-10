registerCommands = ->
  GitCommit = require './models/git-commit'
  GitAdd = require './models/git-add'
  GitBranch = require './models/git-branch'
  GitPull = require './models/git-pull'
  GitDiff = require './models/git-diff'
  GitDiffAll = require './models/git-diff-all'
  GitPush = require './models/git-push'
  GitFetch = require './models/git-fetch'
  GitCheckoutCurrentFile = require './models/git-checkout-current-file'
  GitCheckoutAllFiles = require './models/git-checkout-all-files'
  GitAddAndCommit = require './models/git-add-and-commit'
  GitCommitAmend = require './models/git-commit-amend'
  GitAddAllAndCommit = require './models/git-add-all-and-commit'
  GitRemove = require './models/git-remove'
  GitLog = require './models/git-log'
  GitShow = require './models/git-show'
  GitTags = require './models/git-tags'
  GitInit = require './models/git-init'
  GitStageFiles = require './models/git-stage-files'
  GitUnstageFiles = require './models/git-unstage-files'
  GitStageHunk = require './models/git-stage-hunk'

  if atom.project.getRepo()?
    atom.workspaceView.unbind 'git-plus:init'
    atom.workspaceView.command 'git-plus:commit', -> GitCommit()
    atom.workspaceView.command 'git-plus:commit-amend', -> GitCommitAmend()
    atom.workspaceView.command 'git-plus:add', -> GitAdd()
    atom.workspaceView.command 'git-plus:checkout-current-file', -> GitCheckoutCurrentFile()
    atom.workspaceView.command 'git-plus:checkout-all-files', -> GitCheckoutAllFiles()
    atom.workspaceView.command 'git-plus:diff', -> GitDiff()
    atom.workspaceView.command 'git-plus:diff-all', -> GitDiffAll()
    atom.workspaceView.command 'git-plus:add-all', -> GitAdd(true)
    atom.workspaceView.command 'git-plus:checkout', -> GitBranch.gitBranches()
    atom.workspaceView.command 'git-plus:new-branch', -> GitBranch.newBranch()
    atom.workspaceView.command 'git-plus:pull', -> GitPull()
    atom.workspaceView.command 'git-plus:push', -> GitPush()
    atom.workspaceView.command 'git-plus:fetch', -> GitFetch()
    atom.workspaceView.command 'git-plus:add-and-commit', -> GitAddAndCommit()
    atom.workspaceView.command 'git-plus:add-all-and-commit', -> GitAddAllAndCommit()
    atom.workspaceView.command 'git-plus:remove', -> GitRemove(true)
    atom.workspaceView.command 'git-plus:remove-current-file', -> GitRemove()
    atom.workspaceView.command 'git-plus:log', -> GitLog()
    atom.workspaceView.command 'git-plus:log-current-file', -> GitLog(true)
    atom.workspaceView.command 'git-plus:show', -> GitShow()
    atom.workspaceView.command 'git-plus:tags', -> GitTags()
    atom.workspaceView.command 'git-plus:stage-files', -> GitStageFiles()
    atom.workspaceView.command 'git-plus:unstage-files', -> GitUnstageFiles()
    atom.workspaceView.command 'git-plus:stage-hunk', -> GitStageHunk()
  else
    atom.workspaceView.command 'git-plus:init', -> GitInit()
    atom.workspaceView.unbind 'git-plus:commit'
    atom.workspaceView.unbind 'git-plus:commit-amend'
    atom.workspaceView.unbind 'git-plus:add'
    atom.workspaceView.unbind 'git-plus:checkout-current-file'
    atom.workspaceView.unbind 'git-plus:checkout-all-files'
    atom.workspaceView.unbind 'git-plus:diff'
    atom.workspaceView.unbind 'git-plus:diff-all'
    atom.workspaceView.unbind 'git-plus:add-all'
    atom.workspaceView.unbind 'git-plus:checkout'
    atom.workspaceView.unbind 'git-plus:new-branch'
    atom.workspaceView.unbind 'git-plus:pull'
    atom.workspaceView.unbind 'git-plus:push'
    atom.workspaceView.unbind 'git-plus:fetch'
    atom.workspaceView.unbind 'git-plus:add-and-commit'
    atom.workspaceView.unbind 'git-plus:add-all-and-commit'
    atom.workspaceView.unbind 'git-plus:remove'
    atom.workspaceView.unbind 'git-plus:remove-current-file'
    atom.workspaceView.unbind 'git-plus:log'
    atom.workspaceView.unbind 'git-plus:log-current-file'
    atom.workspaceView.unbind 'git-plus:show'
    atom.workspaceView.unbind 'git-plus:tags'
    atom.workspaceView.unbind 'git-plus:stage-files'
    atom.workspaceView.unbind 'git-plus:unstage-files'
    atom.workspaceView.unbind 'git-plus:stage-hunk'

module.exports = registerCommands
