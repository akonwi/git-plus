contextPackageFinder = require '../../context-package-finder'
git = require '../../git'
notifier = require '../../notifier'
GitDiffBranches = require '../git-diff-branches'

module.exports = ->
  if path = contextPackageFinder.get()?.selectedPath
    git.getRepoForPath(path).then (repo) -> GitDiffBranches(repo)
  else
    notifier.addInfo "No repository found"
