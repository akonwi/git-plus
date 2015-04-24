git = require '../git'
ListView = require '../views/delete-branch-view'

gitDeleteLocalBranch = (repo) ->
  git.cmd
    args: ['branch']
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> new ListView(repo, data.toString())

module.exports = gitDeleteLocalBranch
