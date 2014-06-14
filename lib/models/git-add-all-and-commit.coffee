git = require '../git'
GitCommit = require './git-commit'

gitAddAllAndCommit = ->
  git.add
    stdout: -> GitCommit()

module.exports = gitAddAllAndCommit
