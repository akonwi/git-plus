git = require '../git'
GitCommit = require './git-commit'

gitAddAllAndCommit = ->
  git.add
    exit: -> new GitCommit

module.exports = gitAddAllAndCommit
