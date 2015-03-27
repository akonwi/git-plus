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

    atom.commands.add 'atom-workspace', 'git-plus:menu', -> new GitPaletteView()

    if atom.project.getRepositories().length is 0
      atom.commands.add 'atom-workspace', 'git-plus:init', -> GitInit()
    else
      git.refresh()
      if atom.workspace.getActiveEditor()?.getPath()?
        atom.commands.add 'atom-workspace', 'git-plus:add', -> GitAdd()
        atom.commands.add 'atom-workspace', 'git-plus:log-current-file', -> GitLog(true)
        atom.commands.add 'atom-workspace', 'git-plus:remove-current-file', -> GitRemove()
        atom.commands.add 'atom-workspace', 'git-plus:checkout-current-file', -> GitCheckoutCurrentFile()

      atom.commands.add 'atom-workspace', 'git-plus:add-all', -> GitAdd(true)
      atom.commands.add 'atom-workspace', 'git-plus:add-all-and-commit', -> GitAddAllAndCommit()
      atom.commands.add 'atom-workspace', 'git-plus:add-and-commit', -> GitAddAndCommit()
      atom.commands.add 'atom-workspace', 'git-plus:diff', -> GitDiff()
      atom.commands.add 'atom-workspace', 'git-plus:diff-all', -> GitDiffAll()
      atom.commands.add 'atom-workspace', 'git-plus:log', -> GitLog()
      atom.commands.add 'atom-workspace', 'git-plus:status', -> GitStatus()
      atom.commands.add 'atom-workspace', 'git-plus:push', -> GitPush()
      atom.commands.add 'atom-workspace', 'git-plus:pull', -> GitPull()
      atom.commands.add 'atom-workspace', 'git-plus:remove', -> GitRemove(true)
      atom.commands.add 'atom-workspace', 'git-plus:checkout', -> GitBranch.gitBranches()
      atom.commands.add 'atom-workspace', 'git-plus:checkout-all-files', -> GitCheckoutAllFiles()
      atom.commands.add 'atom-workspace', 'git-plus:cherry-pick', -> GitCherryPick()
      atom.commands.add 'atom-workspace', 'git-plus:commit', -> new GitCommit()
      atom.commands.add 'atom-workspace', 'git-plus:commit-amend', -> GitCommitAmend()
      atom.commands.add 'atom-workspace', 'git-plus:fetch', -> GitFetch()
      atom.commands.add 'atom-workspace', 'git-plus:new-branch', -> GitBranch.newBranch()
      atom.commands.add 'atom-workspace', 'git-plus:reset-head', -> git.reset()
      atom.commands.add 'atom-workspace', 'git-plus:show', -> GitShow()
      atom.commands.add 'atom-workspace', 'git-plus:stage-files', -> GitStageFiles()
      atom.commands.add 'atom-workspace', 'git-plus:stage-hunk', -> GitStageHunk()
      atom.commands.add 'atom-workspace', 'git-plus:stash-save', -> GitStashSave()
      atom.commands.add 'atom-workspace', 'git-plus:stash-pop', -> GitStashPop()
      atom.commands.add 'atom-workspace', 'git-plus:stash-keep', -> GitStashApply()
      atom.commands.add 'atom-workspace', 'git-plus:stash-drop', -> GitStashDrop()
      atom.commands.add 'atom-workspace', 'git-plus:tags', -> GitTags()
      atom.commands.add 'atom-workspace', 'git-plus:unstage-files', -> GitUnstageFiles()
      atom.commands.add 'atom-workspace', 'git-plus:run', -> GitRun()
      atom.commands.add 'atom-workspace', 'git-plus:merge', -> GitMerge()
