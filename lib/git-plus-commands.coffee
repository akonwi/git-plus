git = require './git'

getCommands = ->
  GitAdd                 = require './models/git-add'
  GitBranch              = require './models/git-branch'
  GitDeleteLocalBranch   = require './models/git-delete-local-branch.coffee'
  GitDeleteRemoteBranch  = require './models/git-delete-remote-branch.coffee'
  GitCheckoutAllFiles    = require './models/git-checkout-all-files'
  GitCheckoutCurrentFile = require './models/git-checkout-current-file'
  GitCherryPick          = require './models/git-cherry-pick'
  GitCommit              = require './models/git-commit'
  GitCommitAmend         = require './models/git-commit-amend'
  GitDiff                = require './models/git-diff'
  GitDifftool            = require './models/git-difftool'
  GitDiffAll             = require './models/git-diff-all'
  GitFetch               = require './models/git-fetch'
  GitFetchPrune          = require './models/git-fetch-prune.coffee'
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
  GitRebase              = require './models/git-rebase'

  git.getRepo()
    .then (repo) ->
      currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
      git.refresh()
      commands = []
      commands.push ['git-plus:add', 'Add', -> GitAdd(repo)]
      commands.push ['git-plus:add-all', 'Add All', -> GitAdd(repo, addAll: true)]
      commands.push ['git-plus:log', 'Log', -> GitLog(repo)]
      commands.push ['git-plus:log-current-file', 'Log Current File', -> GitLog(repo, onlyCurrentFile: true)]
      commands.push ['git-plus:remove-current-file', 'Remove Current File', -> GitRemove(repo)]
      commands.push ['git-plus:checkout-all-files', 'Checkout All Files', -> GitCheckoutAllFiles(repo)]
      commands.push ['git-plus:checkout-current-file', 'Checkout Current File', -> GitCheckoutCurrentFile(repo)]
      commands.push ['git-plus:commit', 'Commit', -> GitCommit(repo)]
      commands.push ['git-plus:commit-all', 'Commit All', -> GitCommit(repo, stageChanges: true)]
      commands.push ['git-plus:commit-amend', 'Commit Amend', -> GitCommitAmend(repo)]
      commands.push ['git-plus:add-and-commit', 'Add And Commit', -> git.add(repo, file: currentFile).then -> GitCommit(repo)]
      commands.push ['git-plus:add-all-and-commit', 'Add All And Commit', -> git.add(repo).then -> GitCommit(repo)]
      commands.push ['git-plus:add-all-commit-and-push', 'Add All, Commit And Push', -> git.add(repo).then -> GitCommit(repo, andPush: true)]
      commands.push ['git-plus:checkout', 'Checkout', -> GitBranch.gitBranches(repo)]
      commands.push ['git-plus:checkout-remote', 'Checkout Remote', -> GitBranch.gitRemoteBranches(repo)]
      commands.push ['git-plus:new-branch', 'Checkout New Branch', -> GitBranch.newBranch(repo)]
      commands.push ['git-plus:delete-local-branch', 'Delete Local Branch', -> GitDeleteLocalBranch(repo)]
      commands.push ['git-plus:delete-remote-branch', 'Delete Remote Branch', -> GitDeleteRemoteBranch(repo)]
      commands.push ['git-plus:cherry-pick', 'Cherry-Pick', -> GitCherryPick(repo)]
      commands.push ['git-plus:diff', 'Diff', -> GitDiff(repo, file: currentFile)]
      commands.push ['git-plus:difftool', 'Difftool', -> GitDifftool(repo)]
      commands.push ['git-plus:diff-all', 'Diff All', -> GitDiffAll(repo)]
      commands.push ['git-plus:fetch', 'Fetch', -> GitFetch(repo)]
      commands.push ['git-plus:fetch-prune', 'Fetch Prune', -> GitFetchPrune(repo)]
      commands.push ['git-plus:pull', 'Pull', -> GitPull(repo)]
      commands.push ['git-plus:pull-using-rebase', 'Pull Using Rebase', -> GitPull(repo, rebase: true)]
      commands.push ['git-plus:push', 'Push', -> GitPush(repo)]
      commands.push ['git-plus:remove', 'Remove', -> GitRemove(repo, showSelector: true)]
      commands.push ['git-plus:reset', 'Reset HEAD', -> git.reset(repo)]
      commands.push ['git-plus:show', 'Show', -> GitShow(repo)]
      commands.push ['git-plus:stage-files', 'Stage Files', -> GitStageFiles(repo)]
      commands.push ['git-plus:unstage-files', 'Unstage Files', -> GitUnstageFiles(repo)]
      commands.push ['git-plus:stage-hunk', 'Stage Hunk', -> GitStageHunk(repo)]
      commands.push ['git-plus:stash-save-changes', 'Stash: Save Changes', -> GitStashSave(repo)]
      commands.push ['git-plus:stash-pop', 'Stash: Apply (Pop)', -> GitStashPop(repo)]
      commands.push ['git-plus:stash-apply', 'Stash: Apply (Keep)', -> GitStashApply(repo)]
      commands.push ['git-plus:stash-delete', 'Stash: Delete (Drop)', -> GitStashDrop(repo)]
      commands.push ['git-plus:status', 'Status', -> GitStatus(repo)]
      commands.push ['git-plus:tags', 'Tags', -> GitTags(repo)]
      commands.push ['git-plus:run', 'Run', -> new GitRun(repo)]
      commands.push ['git-plus:merge', 'Merge', -> GitMerge(repo)]
      commands.push ['git-plus:merge-remote', 'Merge Remote', -> GitMerge(repo, remote: true)]
      commands.push ['git-plus:rebase', 'Rebase', -> GitRebase(repo)]

      return commands

module.exports = getCommands
