git = require '../git'
StatusView = require '../views/status-view'

gitStashDrop = ->
  git.cmd
    args: ['stash', 'drop'],
    options: {
      env: process.env.NODE_ENV
    }
    stdout: (data) -> new StatusView(type: 'success', message: data)

module.exports = gitStashDrop
