Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'
StatusView = require '../views/status-view'
gitCommit = require './git-commit'

gitCommitAmend = ->
  git.cmd
    args: ['log', '-1', '--format=%s'],
    stdout: (data) -> gitCommit "- " + data.toString()

module.exports = gitCommitAmend
