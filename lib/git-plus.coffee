{CompositeDisposable} = require 'atom'
{$} = require 'atom-space-pen-views'
git = require './git'
OutputViewManager      = require './output-view-manager'
GitPaletteView         = require './views/git-palette-view'
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
GitStashSaveMessage    = require './models/git-stash-save-message'
GitStatus              = require './models/git-status'
GitTags                = require './models/git-tags'
GitUnstageFiles        = require './models/git-unstage-files'
GitRun                 = require './models/git-run'
GitMerge               = require './models/git-merge'
GitRebase              = require './models/git-rebase'
GitOpenChangedFiles    = require './models/git-open-changed-files'

currentFile = (repo) ->
  repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())

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
      default: 'Down'
      description: 'Where should new panes go? (Defaults to Right)'
      enum: ['Up', 'Right', 'Down', 'Left']
    wordDiff:
      type: 'boolean'
      default: true
      description: 'Should word diffs be highlighted in diffs?'
    numberOfCommitsToShow:
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
    pullBeforePush:
      description: 'Pull from remote before pushing'
      type: 'string'
      default: 'no'
      enum: ['no', 'pull', 'pull --rebase']
    experimental:
      description: 'Enable beta features and behavior'
      type: 'boolean'
      default: false
    verboseCommits:
      description: '(Experimental) Show diffs in commit pane?'
      type: 'boolean'
      default: false

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    repos = atom.project.getRepositories().filter (r) -> r?
    if repos.length is 0
      @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:init', -> GitInit()
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:menu', -> new GitPaletteView()
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:add', -> git.getRepo().then((repo) -> GitAdd(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:add-all', -> git.getRepo().then((repo) -> GitAdd(repo, addAll: true))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:commit', -> git.getRepo().then((repo) -> GitCommit(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:commit-all', -> git.getRepo().then((repo) -> GitCommit(repo, stageChanges: true))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:commit-amend', -> git.getRepo().then((repo) -> new GitCommitAmend(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:add-and-commit', -> git.getRepo().then((repo) -> git.add(repo, file: currentFile(repo)).then -> GitCommit(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:add-and-commit-and-push', -> git.getRepo().then((repo) -> git.add(repo, file: currentFile(repo)).then -> GitCommit(repo, andPush: true))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:add-all-and-commit', -> git.getRepo().then((repo) -> git.add(repo).then -> GitCommit(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:add-all-commit-and-push', -> git.getRepo().then((repo) -> git.add(repo).then -> GitCommit(repo, andPush: true))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:checkout', -> git.getRepo().then((repo) -> GitBranch.gitBranches(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:checkout-remote', -> git.getRepo().then((repo) -> GitBranch.gitRemoteBranches(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:checkout-current-file', -> git.getRepo().then((repo) -> GitCheckoutCurrentFile(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:checkout-all-files', -> git.getRepo().then((repo) -> GitCheckoutAllFiles(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:new-branch', -> git.getRepo().then((repo) -> GitBranch.newBranch(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:delete-local-branch', -> git.getRepo().then((repo) -> GitDeleteLocalBranch(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:delete-remote-branch', -> git.getRepo().then((repo) -> GitDeleteRemoteBranch(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:cherry-pick', -> git.getRepo().then((repo) -> GitCherryPick(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:diff', -> git.getRepo().then((repo) -> GitDiff(repo, file: currentFile(repo)))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:difftool', -> git.getRepo().then((repo) -> GitDifftool(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:diff-all', -> git.getRepo().then((repo) -> GitDiffAll(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:fetch', -> git.getRepo().then((repo) -> GitFetch(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:fetch-prune', -> git.getRepo().then((repo) -> GitFetchPrune(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:pull', -> git.getRepo().then((repo) -> GitPull(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:pull-using-rebase', -> git.getRepo().then((repo) -> GitPull(repo, rebase: true))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:push', -> git.getRepo().then((repo) -> GitPush(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:remove', -> git.getRepo().then((repo) -> GitRemove(repo, showSelector: true))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:remove-current-file', -> git.getRepo().then((repo) -> GitRemove(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:reset', -> git.getRepo().then((repo) -> git.reset(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:show', -> git.getRepo().then((repo) -> GitShow(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:log', -> git.getRepo().then((repo) -> GitLog(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:log-current-file', -> git.getRepo().then((repo) -> GitLog(repo, onlyCurrentFile: true))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:stage-files', -> git.getRepo().then((repo) -> GitStageFiles(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:unstage-files', -> git.getRepo().then((repo) -> GitUnstageFiles(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:stage-hunk', -> git.getRepo().then((repo) -> GitStageHunk(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:stash-save', -> git.getRepo().then((repo) -> GitStashSave(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:stash-save-message', -> git.getRepo().then((repo) -> GitStashSaveMessage(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:stash-pop', -> git.getRepo().then((repo) -> GitStashPop(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:stash-apply', -> git.getRepo().then((repo) -> GitStashApply(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:stash-delete', -> git.getRepo().then((repo) -> GitStashDrop(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:status', -> git.getRepo().then((repo) -> GitStatus(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:tags', -> git.getRepo().then((repo) -> GitTags(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:run', -> git.getRepo().then((repo) -> new GitRun(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:merge', -> git.getRepo().then((repo) -> GitMerge(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:merge-remote', -> git.getRepo().then((repo) -> GitMerge(repo, remote: true))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:rebase', -> git.getRepo().then((repo) -> GitRebase(repo))
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-plus:git-open-changed-files', -> git.getRepo().then((repo) -> GitOpenChangedFiles(repo))

  deactivate: ->
    @subscriptions.dispose()
    @statusBarTile?.destroy()
    delete @statusBarTile

  consumeStatusBar: (statusBar) ->
    @setupBranchesMenuToggle statusBar
    @setupOutputViewToggle statusBar

  setupOutputViewToggle: (statusBar) ->
    div = document.createElement 'div'
    div.classList.add 'inline-block'
    icon = document.createElement 'span'
    icon.classList.add 'icon', 'icon-pin'
    link = document.createElement 'a'
    link.appendChild icon
    link.onclick = (e) -> OutputViewManager.getView().toggle()
    link.title = "Toggle Output Console"
    div.appendChild link
    @statusBarTile = statusBar.addRightTile item: div, priority: 0

  setupBranchesMenuToggle: (statusBar) ->
    statusBar.getRightTiles().some ({item}) =>
      if item?.classList?.contains? 'git-view'
        $(item).find('.git-branch').on 'click', (e) ->
          atom.commands.dispatch(document.querySelector('atom-workspace'), 'git-plus:checkout')
        return true
