GitPlusCommands = require './git-plus-commands'

module.exports =
  configDefaults:
    includeStagedDiff: true
    openInPane: true
    wordDiff: true
    amountOfCommitsToShow: 25

  activate: (state) -> GitPlusCommands()

  deactivate: ->

  serialize: ->
