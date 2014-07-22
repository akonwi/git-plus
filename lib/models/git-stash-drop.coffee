git = require '../git'
StatusView = require '../views/status-view'

gitStashDrop = ->
  git.cmd
    args: ['stash', 'drop'],
    stdout: (data) -> new StatusView(type: 'success', message: data)

module.exports = gitStashDrop
