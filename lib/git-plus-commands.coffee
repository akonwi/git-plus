git = require './git'

getCommands = ->
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
  GitCherryPick = require './models/git-cherry-pick'
  
  commands = []
  if atom.project.getRepo()?
    git.refresh()
    commands.push ['git-plus:commit', 'Git Plus: Commit', -> GitCommit()]
    commands.push ['git-plus:commit-amend', 'Git Plus: Commit Amend', -> GitCommitAmend()]
    commands.push ['git-plus:add', 'Git Plus: Add', -> GitAdd()]
    commands.push ['git-plus:checkout-current-file', 'Git Plus: Checkout Current File', -> GitCheckoutCurrentFile()]
    commands.push ['git-plus:checkout-all-files', 'Git Plus: Checkout All Files', -> GitCheckoutAllFiles()]
    commands.push ['git-plus:diff', 'Git Plus: Diff', -> GitDiff()]
    commands.push ['git-plus:diff-all', 'Git Plus: Diff All', -> GitDiffAll()]
    commands.push ['git-plus:add-all', 'Git Plus: Add All', -> GitAdd(true)]
    commands.push ['git-plus:checkout', 'Git Plus: Checkout', -> GitBranch.gitBranches()]
    commands.push ['git-plus:new-branch', 'Git Plus: Checkout New Branch', -> GitBranch.newBranch()]
    commands.push ['git-plus:pull', 'Git Plus: Pull', -> GitPull()]
    commands.push ['git-plus:push', 'Git Plus: Push', -> GitPush()]
    commands.push ['git-plus:fetch', 'Git Plus: Fetch', -> GitFetch()]
    commands.push ['git-plus:add-and-commit', 'Git Plus: Add And Commit', -> GitAddAndCommit()]
    commands.push ['git-plus:add-all-and-commit', 'Git Plus: Add All And Commit', -> GitAddAllAndCommit()]
    commands.push ['git-plus:remove', 'Git Plus: Remove', -> GitRemove(true)]
    commands.push ['git-plus:remove-current-file', 'Git Plus: Remove Current File', -> GitRemove()]
    commands.push ['git-plus:log', 'Git Plus: Log', -> GitLog()]
    commands.push ['git-plus:log-current-file', 'Git Plus: Log Current File', -> GitLog(true)]
    commands.push ['git-plus:show', 'Git Plus: Show', -> GitShow()]
    commands.push ['git-plus:tags', 'Git Plus: Tags', -> GitTags()]
    commands.push ['git-plus:stage-files', 'Git Plus: Stage Files', -> GitStageFiles()]
    commands.push ['git-plus:unstage-files', 'Git Plus: Unstage Files', -> GitUnstageFiles()]
    commands.push ['git-plus:stage-hunk', 'Git Plus: Stage Hunk', -> GitStageHunk()]
    commands.push ['git-plus:cherry-pick', 'Git Plus: Cherry-Pick', -> GitCherryPick()]
  else
    commands.push ['git-plus:init', 'Git Plus: Init', -> GitInit()]
  
  commands
    
module.exports = getCommands
