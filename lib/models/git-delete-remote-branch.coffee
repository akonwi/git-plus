git = require '../git'
ListView = require '../views/delete-branch-view'

gitDeleteRemoteBranch = (repo) ->
  git.cmd
    args: ['branch', '-r']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      new ListView(repo, data.toString(), isRemote: true)

module.exports = gitDeleteRemoteBranch
