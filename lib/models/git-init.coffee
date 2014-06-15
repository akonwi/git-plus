git = require '../git'
StatusView = require '../views/status-view'
GitPlusCommands = require '../git-plus-commands'

gitInit = ->
  git.cmd
    args: ['init'],
    stdout: (data) ->
      new StatusView(type: 'success', message: data)
      atom.project.setPath(atom.project.getPath())

module.exports = gitInit
