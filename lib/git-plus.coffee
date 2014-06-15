GitAdd = require './models/git-add'
GitCommit = require './models/git-commit'
GitAddAndCommit = require './models/git-add-and-commit'
GitAddAllAndCommit = require './models/git-add-all-and-commit'
GitStatus = require './models/git-status'
GitLog = require './models/git-log'
GitDiff = require './models/git-diff'
GitDiffAll = require './models/git-diff-all'

GitPaletteView = require './views/git-palette-view'

module.exports =
  configDefaults:
    includeStagedDiff: true
    openInPane: true
    splitPane: 'right'
    wordDiff: true
    amountOfCommitsToShow: 25
    gitPath: 'git'

  activate: (state) ->
    atom.workspaceView.command 'git-plus:menu', -> new GitPaletteView()

    # Only keybindings get here as well!
    atom.workspaceView.command 'git-plus:add', -> GitAdd()
    atom.workspaceView.command 'git-plus:commit', -> new GitCommit
    atom.workspaceView.command 'git-plus:add-and-commit', -> GitAddAndCommit()
    atom.workspaceView.command 'git-plus:add-all-and-commit', -> GitAddAllAndCommit()
    atom.workspaceView.command 'git-plus:status', -> GitStatus()
    atom.workspaceView.command 'git-plus:log', -> GitLog()
    atom.workspaceView.command 'git-plus:diff', -> GitDiff()
    atom.workspaceView.command 'git-plus:diff-all', -> GitDiffAll()
