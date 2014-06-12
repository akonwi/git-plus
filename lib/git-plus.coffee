GitPlusCommands = require './git-plus-commands'
git = require './git'

module.exports =
  configDefaults:
    includeStagedDiff: true
    openInPane: true
    wordDiff: true
    amountOfCommitsToShow: 25
    gitPath: 'git'

  activate: (state) ->
    GitPlusCommands()
    git.refresh() if atom.project.getRepo()?

  deactivate: ->

  serialize: ->
