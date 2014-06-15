Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

git = require '../git'
StatusView = require '../views/status-view'
GitCommit = require './git-commit'

gitCommitAmend = ->
  git.cmd
    args: ['log', '-1', '--format=%B'],
    stdout: (amend) ->
      git.cmd
        args: ['reset', '--soft', 'HEAD^']
        exit: -> new GitCommit("#{amend?.trim()}\n")

module.exports = gitCommitAmend
