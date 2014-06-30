{$} = require 'atom'

module.exports =
  configDefaults:
    includeStagedDiff: true
    openInPane: true
    splitPane: 'right'
    wordDiff: true
    amountOfCommitsToShow: 25
    gitPath: 'git'

  activate: (state) ->
    GitAdd             = require './models/git-add'
    GitAddAllAndCommit = require './models/git-add-all-and-commit'
    GitAddAndCommit    = require './models/git-add-and-commit'
    GitCommit          = require './models/git-commit'
    GitDiff            = require './models/git-diff'
    GitDiffAll         = require './models/git-diff-all'
    GitLog             = require './models/git-log'
    GitPaletteView     = require './views/git-palette-view'
    GitStatus          = require './models/git-status'
    GitPush            = require './models/git-push'
    GitPull            = require './models/git-pull'

    atom.workspaceView.command 'git-plus:menu', -> new GitPaletteView()

    # Only keybindings get here as well!
    $(window).on 'git-plus:add',                -> GitAdd()
    $(window).on 'git-plus:add-all-and-commit', -> GitAddAllAndCommit()
    $(window).on 'git-plus:add-and-commit',     -> GitAddAndCommit()
    $(window).on 'git-plus:commit',             -> new GitCommit()
    $(window).on 'git-plus:diff',               -> GitDiff()
    $(window).on 'git-plus:diff-all',           -> GitDiffAll()
    $(window).on 'git-plus:log',                -> GitLog()
    $(window).on 'git-plus:status',             -> GitStatus()
    $(window).on 'git-plus:push',               -> GitPush()
    $(window).on 'git-plus:pull',               -> GitPull()
