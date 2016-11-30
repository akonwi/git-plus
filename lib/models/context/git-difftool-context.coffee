contextPackageFinder = require '../../context-package-finder'
notifier = require '../../notifier'
GitDiffTool = require '../git-difftool'

module.exports = (repo, contextCommandMap) ->
  if path = contextPackageFinder.get()?.selectedPath
    contextCommandMap 'difftool', repo: repo, file: repo.relativize(path)
  else
    notifier.addInfo "No file selected to diff"
