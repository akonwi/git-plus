git = require '../git'
ListView = require '../views/remote-list-view'

gitFetch = (repo) ->
  git.cmd
    args: ['remote']
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> new ListView(repo, data.toString(), mode: 'fetch-prune')

module.exports = gitFetch
