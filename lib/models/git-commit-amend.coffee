Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'
StatusView = require '../views/status-view'
gitCommit = require './git-commit'

gitMsg = ->
  git(
    ['log', '-1', '--format=%s'],
    (data) -> gitCommit "- " + data.toString()
  )

module.exports = gitMsg
