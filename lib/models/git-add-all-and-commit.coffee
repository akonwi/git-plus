git = require '../git'
GitCommit = require './git-commit'

gitAddAllAndCommit = ->
  git.cmd(
    args: ['add', '--all', '.'],
    stdout: (data) ->
      GitCommit()
  )

module.exports = gitAddAllAndCommit
