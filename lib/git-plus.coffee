{$} = require 'atom'
git = require './git'
GitPaletteView = require './views/git-palette-view'

module.exports =
  config:
    includeStagedDiff:
      title: 'Include staged diffs?'
      type: 'boolean'
      default: true
    openInPane:
      type: 'boolean'
      default: true
      description: 'Allow commands to open new panes'
    splitPane:
      title: 'Split pane direction'
      type: 'string'
      default: 'right'
      description: 'Where should new panes go?(right or left)'
    wordDiff:
      type: 'boolean'
      default: true
      description: 'Should word diffs be highlighted in diffs?'
    amountOfCommitsToShow:
      type: 'integer'
      default: 25
    gitPath:
      type: 'string'
      default: 'git'
      description: 'Where is your git?'
    messageTimeout:
      type: 'integer'
      default: 5
      description: 'How long should success/error messages be shown?'

  activate: (state) ->
    GitAdd                 = require './models/git-add'
    GitAddAllAndCommit     = require './models/git-add-all-and-commit'
    GitAddAndCommit        = require './models/git-add-and-commit'
    GitBranch              = require './models/git-branch'
    GitCheckoutAllFiles    = require './models/git-checkout-all-files'
    GitCheckoutCurrentFile = require './models/git-checkout-current-file'
    GitCherryPick          = require './models/git-cherry-pick'
    GitCommit              = require './models/git-commit'
    GitCommitAmend         = require './models/git-commit-amend'
    GitDiff                = require './models/git-diff'
    GitDiffAll             = require './models/git-diff-all'
    GitFetch               = require './models/git-fetch'
    GitInit                = require './models/git-init'
    GitLog                 = require './models/git-log'
    GitStatus              = require './models/git-status'
    GitPush                = require './models/git-push'
    GitPull                = require './models/git-pull'
    GitRemove              = require './models/git-remove'
    GitShow                = require './models/git-show'
    GitStageFiles          = require './models/git-stage-files'
    GitStageHunk           = require './models/git-stage-hunk'
    GitStashApply          = require './models/git-stash-apply'
    GitStashDrop           = require './models/git-stash-drop'
    GitStashPop            = require './models/git-stash-pop'
    GitStashSave           = require './models/git-stash-save'
    GitTags                = require './models/git-tags'
    GitUnstageFiles        = require './models/git-unstage-files'
    GitRun                 = require './models/git-run'
    GitMerge               = require './models/git-merge'

    atom.workspaceView.command 'git-plus:menu', -> new GitPaletteView()
    atom.workspaceView.command 'git-plus:add', -> GitAdd()
    atom.workspaceView.command 'git-plus:add-all', -> GitAdd(true)
    atom.workspaceView.command 'git-plus:add-all-and-commit', -> GitAddAllAndCommit()
    atom.workspaceView.command 'git-plus:add-and-commit', -> GitAddAndCommit()
    atom.workspaceView.command 'git-plus:diff', -> GitDiff()
    atom.workspaceView.command 'git-plus:diff-all', -> GitDiffAll()
    atom.workspaceView.command 'git-plus:log', -> GitLog()
    atom.workspaceView.command 'git-plus:log-current-file', -> GitLog(true)
    atom.workspaceView.command 'git-plus:status', -> GitStatus()
    atom.workspaceView.command 'git-plus:push', -> GitPush()
    atom.workspaceView.command 'git-plus:pull', -> GitPull()
    atom.workspaceView.command 'git-plus:remove-current-file', -> GitRemove()
    atom.workspaceView.command 'git-plus:remove', -> GitRemove(true)
    atom.workspaceView.command 'git-plus:checkout-current-file', -> GitCheckoutCurrentFile()
    atom.workspaceView.command 'git-plus:checkout', -> GitBranch.gitBranches()
    atom.workspaceView.command 'git-plus:checkout-all-files', -> GitCheckoutAllFiles()
    atom.workspaceView.command 'git-plus:cherry-pick', -> GitCherryPick()
    atom.workspaceView.command 'git-plus:commit', -> new GitCommit()
    atom.workspaceView.command 'git-plus:commit-amend', -> GitCommitAmend()
    atom.workspaceView.command 'git-plus:fetch', -> GitFetch()
    atom.workspaceView.command 'git-plus:new-branch', -> GitBranch.newBranch()
    atom.workspaceView.command 'git-plus:reset-head', -> git.reset()
    atom.workspaceView.command 'git-plus:show', -> GitShow()
    atom.workspaceView.command 'git-plus:stage-files', -> GitStageFiles()
    atom.workspaceView.command 'git-plus:stage-hunk', -> GitStageHunk()
    atom.workspaceView.command 'git-plus:stash-save', -> GitStashSave()
    atom.workspaceView.command 'git-plus:stash-pop', -> GitStashPop()
    atom.workspaceView.command 'git-plus:stash-keep', -> GitStashApply()
    atom.workspaceView.command 'git-plus:stash-drop', -> GitStashDrop()
    atom.workspaceView.command 'git-plus:tags', -> GitTags()
    atom.workspaceView.command 'git-plus:unstage-files', -> GitUnstageFiles()
    atom.workspaceView.command 'git-plus:init', -> GitInit()
    atom.workspaceView.command 'git-plus:run', -> GitRun()
    atom.workspaceView.command 'git-plus:merge', -> GitMerge()
