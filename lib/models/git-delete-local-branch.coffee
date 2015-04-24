git = require '../git'
ListView = require '../views/delete-branch-view'

gitDeleteLocalBranch = ->
  git.cmd
    args: ['branch'],
    stdout: (data) -> new ListView(data.toString())

module.exports = gitDeleteLocalBranch
