contextPackageFinder = require '../../context-package-finder'
git = require '../../git'
notifier = require '../../notifier'
GitDiffBranchFiles = require '../git-diff-branch-files'

module.exports = ->
  if path = contextPackageFinder.get()?.selectedPath
    git.getRepoForPath(path).then (repo) ->
      GitDiffBranchFiles(repo, path)
  else
    notifier.addInfo "No repository found"
