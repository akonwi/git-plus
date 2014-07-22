git = require '../git'
StatusView = require '../views/status-view'

gitStashSave = ->
  git.cmd
    args: ['stash', 'save'],
    stdout: (data) -> new StatusView(type: 'success', message: data)

module.exports = gitStashSave
