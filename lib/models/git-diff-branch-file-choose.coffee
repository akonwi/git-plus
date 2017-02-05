git = require '../git'
notifier = require '../notifier'
BranchListView = require '../views/branch-list-view'
DiffBranchFilesView = require '../views/diff-branch-files-view'
_repo = null

module.exports =
  class DiffBranchListView extends BranchListView
    initialize: (@repo, @data) ->
      super
      _repo = @repo

    confirmed: ({name}) ->
      name = name.slice(1) if name.startsWith "*"
      console.log("diff-branch-view:", name)
      args = ['diff', '--name-status', _repo.branch, name]
      console.log("diff-branch-view:args", args)
      git.cmd(args, cwd: _repo.getWorkingDirectory())
      .then (data) ->
        console.log("diff-branch-view.then", data)
        new DiffBranchFilesView(_repo, data, name)
