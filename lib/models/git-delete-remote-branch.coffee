git = require '../git'
ListView = require '../views/delete-branch-view'

module.exports = (repo) ->
  git.cmd(['branch', '--no-color', '-r'], cwd: repo.getWorkingDirectory())
  .then (data) -> new ListView(repo, data, isRemote: true)
