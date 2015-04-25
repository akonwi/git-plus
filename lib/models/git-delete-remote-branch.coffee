git = require '../git'
ListView = require '../views/delete-branch-view'

gitDeleteRemoteBranch = ->
  git.cmd
    args: ['branch', '-r'],
    stdout: (data) ->
      console.log data
      new ListView(data.toString())

module.exports = gitDeleteRemoteBranch
