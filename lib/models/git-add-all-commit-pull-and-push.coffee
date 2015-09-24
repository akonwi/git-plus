git = require '../git'
GitCommit = require './git-commit'

gitAddAllCommitPullAndPush = (repo) ->
  git.add repo,
    file: null,
    exit: ->
      new GitCommit(repo, andPush: true, andPull: true)

module.exports = gitAddAllCommitPullAndPush
