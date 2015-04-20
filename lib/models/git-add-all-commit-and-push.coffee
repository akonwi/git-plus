git = require '../git'
GitCommit = require './git-commit'

gitAddAllCommitAndPush = (repo) ->
  git.add repo,
    exit: ->
      new GitCommit(repo, andPush: true)

module.exports = gitAddAllCommitAndPush
