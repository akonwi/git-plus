GitAdd = require './models/git-add'
GitCommit = require './models/git-commit'
GitAddAndCommit = require './models/git-add-and-commit'
GitAddAllAndCommit = require './models/git-add-all-and-commit'
GitStatus = require './models/git-status'

GitPaletteView = require './views/git-palette-view'

module.exports =
  configDefaults:
    includeStagedDiff: true
    openInPane: true
    wordDiff: true
    amountOfCommitsToShow: 25
    gitPath: 'git'

  activate: (state) ->
    atom.workspaceView.command 'git-plus:menu', -> new GitPaletteView()

    # Only keybindings get here aswell!
    atom.workspaceView.command 'git-plus:add', -> GitAdd()
    atom.workspaceView.command 'git-plus:commit', -> new GitCommit
    atom.workspaceView.command 'git-plus:add-and-commit', -> GitAddAndCommit()
    atom.workspaceView.command 'git-plus:add-all-and-commit', -> GitAddAllAndCommit()
    atom.workspaceView.command 'git-plus:status', -> GitStatus()
