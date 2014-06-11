GitPlusCommands = require './git-plus-commands'
GitRefreshIndex = require './models/git-refresh-index'

module.exports =
  configDefaults:
    includeStagedDiff: true
    openInPane: true
    wordDiff: true
    amountOfCommitsToShow: 25

  activate: (state) ->
    GitPlusCommands()
    GitRefreshIndex() if atom.project.getRepo()?


  deactivate: ->

  serialize: ->
