git = require './git'

getCommands = ->
  GitBranch              = require './models/git-branch'
  GitDeleteLocalBranch   = require './models/git-delete-local-branch'
  GitDeleteRemoteBranch  = require './models/git-delete-remote-branch'
  GitCheckoutAllFiles    = require './models/git-checkout-all-files'
  GitCheckoutFile        = require './models/git-checkout-file'
  GitCherryPick          = require './models/git-cherry-pick'
  GitCommit              = require './models/git-commit'
  GitCommitAmend         = require './models/git-commit-amend'
  GitDiff                = require './models/git-diff'
  GitDiffBranches        = require './models/git-diff-branches'
  GitDiffBranchFiles    = require './models/git-diff-branch-files'
  GitDifftool            = require './models/git-difftool'
  GitDiffAll             = require './models/git-diff-all'
  GitFetch               = require './models/git-fetch'
  GitFetchPrune          = require './models/git-fetch-prune'
  GitInit                = require './models/git-init'
  GitLog                 = require './models/git-log'
  GitPull                = require './models/git-pull'
  GitPush                = require './models/git-push'
  GitRemove              = require './models/git-remove'
  GitShow                = require './models/git-show'
  GitStageFiles          = require './models/git-stage-files'
  GitStageFilesBeta      = require './models/git-stage-files-beta'
  GitStageHunk           = require './models/git-stage-hunk'
  GitStashApply          = require './models/git-stash-apply'
  GitStashDrop           = require './models/git-stash-drop'
  GitStashPop            = require './models/git-stash-pop'
  GitStashSave           = require './models/git-stash-save'
  GitStashSaveMessage    = require './models/git-stash-save-message'
  GitStatus              = require './models/git-status'
  GitTags                = require './models/git-tags'
  GitUnstageFiles        = require './models/git-unstage-files'
  GitRun                 = require './models/git-run'
  GitMerge               = require './models/git-merge'
  GitRebase              = require './models/git-rebase'
  GitOpenChangedFiles    = require './models/git-open-changed-files'

  git.getRepo()
    .then (repo) ->
      currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
      git.refresh repo
      commands = []
      if atom.config.get('git-plus.experimental.customCommands')
        commands = commands.concat(require('./service').getCustomCommands())
      commands.push ['git-plus:add', 'Add', -> git.add(repo, file: currentFile)]
      commands.push ['git-plus:add-modified', 'Add Modified', -> git.add(repo, update: true)]
      commands.push ['git-plus:add-all', 'Add All', -> git.add(repo)]
      commands.push ['git-plus:log', 'Log', -> GitLog(repo)]
      commands.push ['git-plus:log-current-file', 'Log Current File', -> GitLog(repo, onlyCurrentFile: true)]
      commands.push ['git-plus:remove-current-file', 'Remove Current File', -> GitRemove(repo)]
      commands.push ['git-plus:checkout-all-files', 'Checkout All Files', -> GitCheckoutAllFiles(repo)]
      commands.push ['git-plus:checkout-current-file', 'Checkout Current File', -> GitCheckoutFile(repo, file: currentFile)]
      commands.push ['git-plus:commit', 'Commit', -> GitCommit(repo)]
      commands.push ['git-plus:commit-all', 'Commit All', -> GitCommit(repo, stageChanges: true)]
      commands.push ['git-plus:commit-amend', 'Commit Amend', -> GitCommitAmend(repo)]
      commands.push ['git-plus:add-and-commit', 'Add And Commit', -> git.add(repo, file: currentFile).then -> GitCommit(repo)]
      commands.push ['git-plus:add-and-commit-and-push', 'Add And Commit And Push', -> git.add(repo, file: currentFile).then -> GitCommit(repo, andPush: true)]
      commands.push ['git-plus:add-all-and-commit', 'Add All And Commit', -> git.add(repo).then -> GitCommit(repo)]
      commands.push ['git-plus:add-all-commit-and-push', 'Add All, Commit And Push', -> git.add(repo).then -> GitCommit(repo, andPush: true)]
      commands.push ['git-plus:commit-all-and-push', 'Commit All And Push', -> GitCommit(repo, stageChanges: true, andPush: true)]
      commands.push ['git-plus:checkout', 'Checkout', -> GitBranch.gitBranches(repo)]
      commands.push ['git-plus:checkout-remote', 'Checkout Remote', -> GitBranch.gitRemoteBranches(repo)]
      commands.push ['git-plus:new-branch', 'Checkout New Branch', -> GitBranch.newBranch(repo)]
      commands.push ['git-plus:delete-local-branch', 'Delete Local Branch', -> GitDeleteLocalBranch(repo)]
      commands.push ['git-plus:delete-remote-branch', 'Delete Remote Branch', -> GitDeleteRemoteBranch(repo)]
      commands.push ['git-plus:cherry-pick', 'Cherry-Pick', -> GitCherryPick(repo)]
      commands.push ['git-plus:diff', 'Diff', -> GitDiff(repo, file: currentFile)]
      if atom.config.get('git-plus.experimental.diffBranches')
        commands.push ['git-plus:diff-branches', 'Diff branches', -> GitDiffBranches(repo)]
        commands.push ['git-plus:diff-branch-files', 'Diff branch files', -> GitDiffBranchFiles(repo)]
      commands.push ['git-plus:difftool', 'Difftool', -> GitDifftool(repo)]
      commands.push ['git-plus:diff-all', 'Diff All', -> GitDiffAll(repo)]
      commands.push ['git-plus:fetch', 'Fetch', -> GitFetch(repo)]
      commands.push ['git-plus:fetch-prune', 'Fetch Prune', -> GitFetchPrune(repo)]
      commands.push ['git-plus:pull', 'Pull', -> GitPull(repo)]
      commands.push ['git-plus:push', 'Push', -> GitPush(repo)]
      commands.push ['git-plus:push-set-upstream', 'Push -u', -> GitPush(repo, setUpstream: true)]
      commands.push ['git-plus:remove', 'Remove', -> GitRemove(repo, showSelector: true)]
      commands.push ['git-plus:reset', 'Reset HEAD', -> git.reset(repo)]
      commands.push ['git-plus:show', 'Show', -> GitShow(repo)]
      if atom.config.get('git-plus.experimental.stageFilesBeta')
        commands.push ['git-plus:stage-files', 'Stage Files', -> GitStageFilesBeta(repo)]
      else
        commands.push ['git-plus:stage-files', 'Stage Files', -> GitStageFiles(repo)]
        commands.push ['git-plus:unstage-files', 'Unstage Files', -> GitUnstageFiles(repo)]
      commands.push ['git-plus:stage-hunk', 'Stage Hunk', -> GitStageHunk(repo)]
      commands.push ['git-plus:stash-save', 'Stash: Save Changes', -> GitStashSave(repo)]
      commands.push ['git-plus:stash-save-message', 'Stash: Save Changes With Message', -> GitStashSaveMessage(repo)]
      commands.push ['git-plus:stash-pop', 'Stash: Apply (Pop)', -> GitStashPop(repo)]
      commands.push ['git-plus:stash-apply', 'Stash: Apply (Keep)', -> GitStashApply(repo)]
      commands.push ['git-plus:stash-delete', 'Stash: Delete (Drop)', -> GitStashDrop(repo)]
      commands.push ['git-plus:status', 'Status', -> GitStatus(repo)]
      commands.push ['git-plus:tags', 'Tags', -> GitTags(repo)]
      commands.push ['git-plus:run', 'Run', -> new GitRun(repo)]
      commands.push ['git-plus:merge', 'Merge', -> GitMerge(repo)]
      commands.push ['git-plus:merge-remote', 'Merge Remote', -> GitMerge(repo, remote: true)]
      commands.push ['git-plus:merge-no-fast-forward', 'Merge without fast-forward', -> GitMerge(repo, noFastForward: true)]
      commands.push ['git-plus:rebase', 'Rebase', -> GitRebase(repo)]
      commands.push ['git-plus:git-open-changed-files', 'Open Changed Files', -> GitOpenChangedFiles(repo)]

      return commands

module.exports = getCommands
