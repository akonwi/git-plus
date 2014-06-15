git = require '../git'
GitCommit = require './git-commit'

gitAddAndCommit = ->
  git.add
    file: atom.project.relativize(atom.workspace.getActiveEditor()?.getPath())
    exit: -> new GitCommit

module.exports = gitAddAndCommit
