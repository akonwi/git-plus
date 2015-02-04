git = require '../git'
StatusView = require '../views/status-view'

gitStashPop = ->
  git.cmd
    args: ['stash', 'pop'],
    options: {
      env: process.env.NODE_ENV
    }
    stdout: (data) -> new StatusView(type: 'success', message: data)

module.exports = gitStashPop
