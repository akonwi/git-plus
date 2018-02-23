git = require '../git'
notifier = require '../notifier'
BranchListView = require '../views/branch-list-view'
DiffBranchFilesView = require '../views/diff-branch-files-view'

module.exports = (repo, filePath) ->
  git.cmd(['branch', '--no-color'], cwd: repo.getWorkingDirectory())
  .then (branches) ->
    new BranchListView branches, ({name}) ->
      branchName = name
      args = ['diff', '--name-status', repo.branch, branchName]
      git.cmd(args, cwd: repo.getWorkingDirectory())
      .then (diffData) ->
        new DiffBranchFilesView(repo, diffData, branchName, filePath)
      .catch notifier.addError
