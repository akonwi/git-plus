git = require './git'

getCommands = ->
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
  GitPull                = require './models/git-pull'
  GitPush                = require './models/git-push'
  GitRemove              = require './models/git-remove'
  GitShow                = require './models/git-show'
  GitStageFiles          = require './models/git-stage-files'
  GitStageHunk           = require './models/git-stage-hunk'
  GitStashApply          = require './models/git-stash-apply'
  GitStashDrop           = require './models/git-stash-drop'
  GitStashPop            = require './models/git-stash-pop'
  GitStashSave           = require './models/git-stash-save'
  GitStatus              = require './models/git-status'
  GitTags                = require './models/git-tags'
  GitUnstageFiles        = require './models/git-unstage-files'
  GitRun                 = require './models/git-run'
  GitMerge               = require './models/git-merge'

  commands = []
  # If no file open and if no repo for project
  noOpenFile = not atom.workspace.getActiveEditor()?.getPath()?
  noRepoHere = noOpenFile and atom.project.getRepositories().length is 0
  if noRepoHere
    commands.push ['git-plus:init', 'Init', -> GitInit()]
  else # there is an open file or repo
    git.refresh()
    # Look for repo
    if git.getRepo() is null
      commands.push ['git-plus:init', 'Init', -> GitInit()]
    else
      commands.push ['git-plus:add', 'Add', -> GitAdd()]
      commands.push ['git-plus:log-current-file', 'Log Current File', -> GitLog(true)]
      commands.push ['git-plus:remove-current-file', 'Remove Current File', -> GitRemove()]
      commands.push ['git-plus:checkout-current-file', 'Checkout Current File', -> GitCheckoutCurrentFile()]

      commands.push ['git-plus:add-all', 'Add All', -> GitAdd(true)]
      commands.push ['git-plus:add-all-and-commit', 'Add All And Commit', -> GitAddAllAndCommit()]
      commands.push ['git-plus:add-and-commit', 'Add And Commit', -> GitAddAndCommit()]
      commands.push ['git-plus:checkout', 'Checkout', -> GitBranch.gitBranches()]
      commands.push ['git-plus:checkout-all-files', 'Checkout All Files', -> GitCheckoutAllFiles()]
      commands.push ['git-plus:cherry-pick', 'Cherry-Pick', -> GitCherryPick()]
      commands.push ['git-plus:commit', 'Commit', -> new GitCommit]
      commands.push ['git-plus:commit-amend', 'Commit Amend', -> GitCommitAmend()]
      commands.push ['git-plus:diff', 'Diff', -> GitDiff()]
      commands.push ['git-plus:diff-all', 'Diff All', -> GitDiffAll()]
      commands.push ['git-plus:fetch', 'Fetch', -> GitFetch()]
      commands.push ['git-plus:log', 'Log', -> GitLog()]
      commands.push ['git-plus:new-branch', 'Checkout New Branch', -> GitBranch.newBranch()]
      commands.push ['git-plus:pull', 'Pull', -> GitPull()]
      commands.push ['git-plus:push', 'Push', -> GitPush()]
      commands.push ['git-plus:remove', 'Remove', -> GitRemove(true)]
      commands.push ['git-plus:reset', 'Reset HEAD', -> git.reset()]
      commands.push ['git-plus:show', 'Show', -> GitShow()]
      commands.push ['git-plus:stage-files', 'Stage Files', -> GitStageFiles()]
      commands.push ['git-plus:stage-hunk', 'Stage Hunk', -> GitStageHunk()]
      commands.push ['git-plus:stash-save-changes', 'Stash: Save Changes', -> GitStashSave()]
      commands.push ['git-plus:stash-pop', 'Stash: Apply (Pop)', -> GitStashPop()]
      commands.push ['git-plus:stash-apply', 'Stash: Apply (Keep)', -> GitStashApply()]
      commands.push ['git-plus:stash-delete', 'Stash: Delete (Drop)', -> GitStashDrop()]
      commands.push ['git-plus:status', 'Status', -> GitStatus()]
      commands.push ['git-plus:tags', 'Tags', -> GitTags()]
      commands.push ['git-plus:unstage-files', 'Unstage Files', -> GitUnstageFiles()]
      commands.push ['git-plus:run', 'Run', -> GitRun()]
      commands.push ['git-plus:merge', 'Merge', -> GitMerge()]

  commands

module.exports = getCommands
