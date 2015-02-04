git = require '../git'
StatusView = require '../views/status-view'

gitStashSave = ->
  git.cmd
    args: ['stash', 'save'],
    options: {
      env: process.env.NODE_ENV
    }
    stdout: (data) -> new StatusView(type: 'success', message: data)

module.exports = gitStashSave
