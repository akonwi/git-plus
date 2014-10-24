git = require '../git'
MergeListView = require '../views/merge-list-view'

module.exports = ->
  git.cmd
    args: ['branch'],
    stdout: (data) ->
      new MergeListView(data)
