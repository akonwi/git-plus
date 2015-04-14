git = require '../git'
GitCommit = require './git-commit'

gitAddAllCommitAndPush = ->
  git.add
    exit: ->
      new GitCommit('',true)

module.exports = gitAddAllCommitAndPush
