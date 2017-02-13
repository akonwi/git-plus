git = require '../git'
DiffBranchFileChooser = require '../views/diff-branch-file-chooser'

module.exports = (repo, filePath) ->
  git.cmd(['branch', '--no-color'], cwd: repo.getWorkingDirectory())
  .then (data) -> new DiffBranchFileChooser(repo, data, filePath)
