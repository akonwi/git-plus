git = require '../git'
GitCommit = require './git-commit'

gitAddAllAndCommit = ->
  git.add
    exit: -> GitCommit()

module.exports = gitAddAllAndCommit
