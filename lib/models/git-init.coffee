git = require '../git'
StatusView = require '../views/status-view'

gitInit = ->
  git.cmd
    args: ['init'],
    stdout: (data) ->
      new StatusView(type: 'success', message: data)
      atom.project.setPath(atom.project.getPath())

module.exports = gitInit
