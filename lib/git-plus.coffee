git = require './git'
GitPaletteView = require './views/git-palette-view'
GitAdd                 = require './models/git-add'
GitAddAllAndCommit     = require './models/git-add-all-and-commit'
GitAddAllCommitAndPush = require './models/git-add-all-commit-and-push'
GitAddAndCommit        = require './models/git-add-and-commit'
GitBranch              = require './models/git-branch'
GitDeleteLocalBranch   = require './models/git-delete-local-branch.coffee'
GitDeleteRemoteBranch  = require './models/git-delete-remote-branch.coffee'
GitCheckoutAllFiles    = require './models/git-checkout-all-files'
GitCheckoutCurrentFile = require './models/git-checkout-current-file'
GitCherryPick          = require './models/git-cherry-pick'
GitCommit              = require './models/git-commit'
GitCommitAmend         = require './models/git-commit-amend'
GitDiff                = require './models/git-diff'
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

module.exports =
  config:
    includeStagedDiff:
      title: 'Include staged diffs?'
      description: 'description'
      type: 'boolean'
      default: true
    openInPane:
      type: 'boolean'
      default: true
      description: 'Allow commands to open new panes'
    splitPane:
      title: 'Split pane direction (up, right, down, or left)'
      type: 'string'
      default: 'right'
      description: 'Where should new panes go? (Defaults to right)'
    wordDiff:
      type: 'boolean'
      default: true
      description: 'Should word diffs be highlighted in diffs?'
    amountOfCommitsToShow:
      type: 'integer'
      default: 25
      minimum: 1
    gitPath:
      type: 'string'
      default: 'git'
      description: 'Where is your git?'
    messageTimeout:
      type: 'integer'
      default: 5
      description: 'How long should success/error messages be shown?'

  activate: (state) ->
    repos = atom.project.getRepositories().filter (r) -> r?
    if repos.length is 0
      atom.commands.add 'atom-workspace', 'git-plus:init', -> GitInit()
    atom.commands.add 'atom-workspace', 'git-plus:menu', -> new GitPaletteView()
    atom.commands.add 'atom-workspace', 'git-plus:add', -> git.getRepo().then((repo) -> GitAdd(repo))
    atom.commands.add 'atom-workspace', 'git-plus:add-all', -> git.getRepo().then((repo) -> GitAdd(repo, addAll: true))
    atom.commands.add 'atom-workspace', 'git-plus:commit', -> git.getRepo().then((repo) -> new GitCommit(repo))
    atom.commands.add 'atom-workspace', 'git-plus:commit-amend', -> git.getRepo().then((repo) -> new GitCommitAmend(repo))
    atom.commands.add 'atom-workspace', 'git-plus:add-and-commit', -> git.getRepo().then((repo) -> GitAddAndCommit(repo))
    atom.commands.add 'atom-workspace', 'git-plus:add-all-and-commit', -> git.getRepo().then((repo) -> GitAddAllAndCommit(repo))
    atom.commands.add 'atom-workspace', 'git-plus:add-all-commit-and-push', -> git.getRepo().then((repo) -> GitAddAllCommitAndPush(repo))
    atom.commands.add 'atom-workspace', 'git-plus:checkout', -> git.getRepo().then((repo) -> GitBranch.gitBranches(repo))
    atom.commands.add 'atom-workspace', 'git-plus:checkout-current-file', -> git.getRepo().then((repo) -> GitCheckoutCurrentFile(repo))
    atom.commands.add 'atom-workspace', 'git-plus:checkout-all-files', -> git.getRepo().then((repo) -> GitCheckoutAllFiles(repo))
    atom.commands.add 'atom-workspace', 'git-plus:new-branch', -> git.getRepo().then((repo) -> GitBranch.newBranch(repo))
    atom.commands.add 'atom-workspace', 'git-plus:delete-local-branch', -> git.getRepo().then((repo) -> GitDeleteLocalBranch(repo))
    atom.commands.add 'atom-workspace', 'git-plus:delete-remote-branch', -> git.getRepo().then((repo) -> GitDeleteRemoteBranch(repo))
    atom.commands.add 'atom-workspace', 'git-plus:cherry-pick', -> git.getRepo().then((repo) -> GitCherryPick(repo))
    atom.commands.add 'atom-workspace', 'git-plus:diff', -> git.getRepo().then((repo) -> GitDiff(repo))
    atom.commands.add 'atom-workspace', 'git-plus:diff-all', -> git.getRepo().then((repo) -> GitDiffAll(repo))
    atom.commands.add 'atom-workspace', 'git-plus:fetch', -> git.getRepo().then((repo) -> GitFetch(repo))
    atom.commands.add 'atom-workspace', 'git-plus:fetch-prune', -> git.getRepo().then((repo) -> GitFetchPrune(repo))
    atom.commands.add 'atom-workspace', 'git-plus:pull', -> git.getRepo().then((repo) -> GitPull(repo))
    atom.commands.add 'atom-workspace', 'git-plus:pull-using-rebase', -> git.getRepo().then((repo) -> GitPull(repo, rebase: true))
    atom.commands.add 'atom-workspace', 'git-plus:push', -> git.getRepo().then((repo) -> GitPush(repo))
    atom.commands.add 'atom-workspace', 'git-plus:remove', -> git.getRepo().then((repo) -> GitRemove(repo, showSelector: true))
    atom.commands.add 'atom-workspace', 'git-plus:remove-current-file', -> git.getRepo().then((repo) -> GitRemove(repo))
    atom.commands.add 'atom-workspace', 'git-plus:reset', -> git.getRepo().then((repo) -> git.reset(repo))
    atom.commands.add 'atom-workspace', 'git-plus:show', -> git.getRepo().then((repo) -> GitShow(repo))
    atom.commands.add 'atom-workspace', 'git-plus:log', -> git.getRepo().then((repo) -> GitLog(repo))
    atom.commands.add 'atom-workspace', 'git-plus:log-current-file', -> git.getRepo().then((repo) -> GitLog(repo, onlyCurrentFile: true))
    atom.commands.add 'atom-workspace', 'git-plus:stage-files', -> git.getRepo().then((repo) -> GitStageFiles(repo))
    atom.commands.add 'atom-workspace', 'git-plus:unstage-files', -> git.getRepo().then((repo) -> GitUnstageFiles(repo))
    atom.commands.add 'atom-workspace', 'git-plus:stage-hunk', -> git.getRepo().then((repo) -> GitStageHunk(repo))
    atom.commands.add 'atom-workspace', 'git-plus:stash-save-changes', -> git.getRepo().then((repo) -> GitStashSave(repo))
    atom.commands.add 'atom-workspace', 'git-plus:stash-pop', -> git.getRepo().then((repo) -> GitStashPop(repo))
    atom.commands.add 'atom-workspace', 'git-plus:stash-apply', -> git.getRepo().then((repo) -> GitStashApply(repo))
    atom.commands.add 'atom-workspace', 'git-plus:stash-delete', -> git.getRepo().then((repo) -> GitStashDrop(repo))
    atom.commands.add 'atom-workspace', 'git-plus:status', -> git.getRepo().then((repo) -> GitStatus(repo))
    atom.commands.add 'atom-workspace', 'git-plus:tags', -> git.getRepo().then((repo) -> GitTags(repo))
    atom.commands.add 'atom-workspace', 'git-plus:run', -> git.getRepo().then((repo) -> new GitRun(repo))
    atom.commands.add 'atom-workspace', 'git-plus:merge', -> git.getRepo().then((repo) -> GitMerge(repo))
