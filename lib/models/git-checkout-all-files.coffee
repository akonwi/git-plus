git = require '../git'
StatusView = require '../views/status-view'
Path = require 'path'

gitCheckoutAllFiles = ->
  git(
    ['checkout', '-f'],
    (data) -> new StatusView(type: 'success', message: data.toString())
  )

module.exports = gitCheckoutAllFiles
