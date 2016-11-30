contextPackageFinder = require '../../context-package-finder'
notifier = require '../../notifier'
GitDiffTool = require '../git-difftool'

module.exports = (repo) ->
  if path = contextPackageFinder.get()?.selectedPath
    GitDiffTool repo, file: repo.relativize(path)
  else
    notifier.addInfo "No file selected to diff"
