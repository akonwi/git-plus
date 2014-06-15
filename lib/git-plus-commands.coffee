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
  GitStatus = require './models/git-status'

  commands = []
  if atom.project.getRepo()?
    git.refresh()
    if atom.workspace.getActiveEditor()?.getPath()?
      commands.push ['git-plus:add', 'Add', -> GitAdd()]
      commands.push ['git-plus:log-current-file', 'Log Current File', -> GitLog(true)]
      commands.push ['git-plus:remove-current-file', 'Remove Current File', -> GitRemove()]
      commands.push ['git-plus:checkout-current-file', 'Checkout Current File', -> GitCheckoutCurrentFile()]

    commands.push ['git-plus:add-and-commit', 'Add And Commit', -> GitAddAndCommit()]
    commands.push ['git-plus:add-all-and-commit', 'Add All And Commit', -> GitAddAllAndCommit()]
    commands.push ['git-plus:commit', 'Commit', -> new GitCommit]
    commands.push ['git-plus:commit-amend', 'Commit Amend', -> GitCommitAmend()]
    commands.push ['git-plus:add-all', 'Add All', -> GitAdd(true)]
    commands.push ['git-plus:checkout-all-files', 'Checkout All Files', -> GitCheckoutAllFiles()]
    commands.push ['git-plus:diff', 'Diff', -> GitDiff()]
    commands.push ['git-plus:diff-all', 'Diff All', -> GitDiffAll()]
    commands.push ['git-plus:checkout', 'Checkout', -> GitBranch.gitBranches()]
    commands.push ['git-plus:new-branch', 'Checkout New Branch', -> GitBranch.newBranch()]
    commands.push ['git-plus:pull', 'Pull', -> GitPull()]
    commands.push ['git-plus:push', 'Push', -> GitPush()]
    commands.push ['git-plus:fetch', 'Fetch', -> GitFetch()]
    commands.push ['git-plus:remove', 'Remove', -> GitRemove(true)]
    commands.push ['git-plus:log', 'Log', -> GitLog()]
    commands.push ['git-plus:show', 'Show', -> GitShow()]
    commands.push ['git-plus:tags', 'Tags', -> GitTags()]
    commands.push ['git-plus:stage-files', 'Stage Files', -> GitStageFiles()]
    commands.push ['git-plus:unstage-files', 'Unstage Files', -> GitUnstageFiles()]
    commands.push ['git-plus:stage-hunk', 'Stage Hunk', -> GitStageHunk()]
    commands.push ['git-plus:cherry-pick', 'Cherry-Pick', -> GitCherryPick()]
    commands.push ['git-plus:status', 'Status', -> GitStatus()]
  else
    commands.push ['git-plus:init', 'Init', -> GitInit()]

  commands

module.exports = getCommands
