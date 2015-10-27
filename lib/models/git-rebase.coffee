git = require '../git'
RebaseListView = require '../views/rebase-list-view'

module.exports = (repo) ->
  git.cmd
    args: ['branch']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      new RebaseListView(repo, data)
