git = require '../git'
GitCommit = require './git-commit'

gitAddAndCommit = (repo) ->
  git.add repo,
    file: repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
    exit: -> new GitCommit(repo)

module.exports = gitAddAndCommit
