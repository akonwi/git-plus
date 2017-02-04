git = require '../git'
notifier = require '../notifier'
BranchListView = require './branch-list-view'
DiffBranchFilesView = require '../views/diff-branch-files-view'
cwd = ''

module.exports =
  class DiffBranchListView extends BranchListView
    initialize: (@repo, @data) -> super

    confirmed: ({name}) ->
      name = name.slice(1) if name.startsWith "*"
      console.log("diff-branch-view:", name)
      args = ['diff', '--name-status', name]
      console.log("diff-branch-view:args", args)
      git.cmd(args, cwd: @repo.getWorkingDirectory())
      .then (data) ->
        console.log("diff-branch-view.then", data)
        new DiffBranchFilesView(@repo, data)
