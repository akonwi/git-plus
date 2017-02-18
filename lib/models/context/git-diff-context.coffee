contextPackageFinder = require '../../context-package-finder'
git = require '../../git'
notifier = require '../../notifier'
GitDiff = require '../git-diff'

module.exports = ->
  if path = contextPackageFinder.get()?.selectedPath
    git.getRepoForPath(path).then (repo) ->
      if path is repo.getWorkingDirectory()
        file = path
      else
        file = repo.relativize(path)
      file = undefined if file is ''
      GitDiff repo, {file}
  else
    notifier.addInfo "No file selected to diff"
