git = require './git'
GitPaletteView = require './views/git-palette-view'
GitAdd = require './models/git-add'
GitCommit = require './models/git-commit'
GitCommitAmend = require './models/git-commit-amend'
GitAddAndCommit = require './models/git-add-and-commit'
GitAddAllAndCommit = require './models/git-add-all-and-commit'
GitAddAllCommitAndPush = require './models/git-add-all-commit-and-push'
GitCheckoutCurrentFile = require './models/git-checkout-current-file'
GitBranch = require './models/git-branch'
GitDiff = require './models/git-diff'
GitDiffAll = require './models/git-diff-all'
GitRemove = require './models/git-remove'
GitShow = require './models/git-show'
GitLog = require './models/git-log'

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
      minimum: 1
    gitPath:
      type: 'string'
      default: 'git'
      description: 'Where is your git?'

  activate: (state) ->
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
    atom.commands.add 'atom-workspace', 'git-plus:diff', -> git.getRepo().then((repo) -> GitDiff(repo))
    atom.commands.add 'atom-workspace', 'git-plus:diff-all', -> git.getRepo().then((repo) -> GitDiffAll(repo))
    atom.commands.add 'atom-workspace', 'git-plus:remove', -> git.getRepo().then((repo) -> GitRemove(repo, showSelector: true))
    atom.commands.add 'atom-workspace', 'git-plus:remove-current-file', -> git.getRepo().then((repo) -> GitRemove(repo))
    atom.commands.add 'atom-workspace', 'git-plus:show', -> git.getRepo().then((repo) -> GitShow(repo))
    atom.commands.add 'atom-workspace', 'git-plus:log', -> git.getRepo().then((repo) -> GitLog(repo))
    atom.commands.add 'atom-workspace', 'git-plus:log-current-file', -> git.getRepo().then((repo) -> GitLog(repo, onlyCurrentFile: true))
