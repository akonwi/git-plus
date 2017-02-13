git = require '../git'
notifier = require '../notifier'
BranchListView = require '../views/branch-list-view'
DiffBranchFilesView = require '../views/diff-branch-files-view'

module.exports =
  class DiffBranchListView extends BranchListView
    initialize: (@repo, @data, @selectedFilePath) -> super

    confirmed: ({name}) ->
      name = name.slice(1) if name.startsWith "*"
      args = ['diff', '--name-status', @repo.branch, name]
      git.cmd(args, cwd: @repo.getWorkingDirectory())
      .then (data) =>
        new DiffBranchFilesView(@repo, data, name, @selectedFilePath)
