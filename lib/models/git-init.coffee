git = require '../git'
StatusView = require '../views/status-view'
GitPlusCommands = require '../git-plus-commands'

gitInit = ->
  git(
    ['init'],
    (data) ->
      new StatusView(type: 'success', message: data)
      atom.project.setPath atom.project.getPath()
      GitPlusCommands()
  )

module.exports = gitInit
