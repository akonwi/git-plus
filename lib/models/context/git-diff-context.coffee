contextPackageFinder = require '../../context-package-finder'
notifier = require '../../notifier'
GitDiff = require '../git-diff'

module.exports = (repo) ->
  if path = contextPackageFinder.get()?.selectedPath
    if path is repo.getWorkingDirectory()
      file = path
    else
      file = repo.relativize(path)
    file = undefined if file is ''
    GitDiff repo, {file}
  else
    notifier.addInfo "No file selected to diff"
