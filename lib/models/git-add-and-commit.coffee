git = require '../git'
GitCommit = require './git-commit'

gitAddAndCommit = ->
  file = atom.project.relativize atom.workspace.getActiveEditor()?.getPath()
  git.cmd
    args: ['add', '--all', file],
    stdout: (data) ->
      GitCommit()

module.exports = gitAddAndCommit
