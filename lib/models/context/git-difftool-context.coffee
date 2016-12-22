contextPackageFinder = require '../../context-package-finder'
git = require '../../git'
notifier = require '../../notifier'
GitDiffTool = require '../git-difftool'

module.exports = ->
  if path = contextPackageFinder.get()?.selectedPath
    git.getRepoForPath(path).then (repo) ->
      GitDiffTool repo, file: repo.relativize(path)
  else
    notifier.addInfo "No file selected to diff"
