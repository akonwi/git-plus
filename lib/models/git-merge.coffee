git = require '../git'
MergeListView = require '../views/merge-list-view'

module.exports = (repo) ->
  git.cmd
    args: ['branch']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      new MergeListView(repo, data)
