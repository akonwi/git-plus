git = require './git'
GitPaletteView = require './views/git-palette-view'
GitInit = require './models/git-init'

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
    messageTimeout:
      type: 'integer'
      default: 5
      description: 'How long should success/error messages be shown?'

  activate: (state) ->
    # repos = atom.project.getRepositories().filter (repo) -> repo?
    # if repos.length is 0
      # atom.commands.add 'atom-workspace', 'git-plus:init', -> GitInit()
    # else
    atom.commands.add 'atom-workspace', 'git-plus:menu', -> new GitPaletteView()
