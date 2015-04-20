git = require '../git'
GitCommit = require './git-commit'

gitAddAllAndCommit = (repo) ->
  git.add repo,
    exit: -> new GitCommit(repo)

module.exports = gitAddAllAndCommit
