GitAdd = require './models/git-add'
GitCommit = require './models/git-commit'
GitAddAndCommit = require './models/git-add-and-commit'
GitAddAllAndCommit = require './models/git-add-all-and-commit'

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
    atom.workspaceView.on 'git-plus:add', -> new GitAdd()
    atom.workspaceView.on 'git-plus:commit', -> new GitCommit()
    atom.workspaceView.on 'git-plus:add-and-commit', -> new GitAddAndCommit()
    atom.workspaceView.on 'git-plus:add-all-and-commit', -> new GitAddAllAndCommit()
