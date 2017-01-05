contextPackageFinder = require '../../context-package-finder'
git = require '../../git'
notifier = require '../../notifier'
GitCommit = require '../git-commit'

module.exports = ->
  if path = contextPackageFinder.get()?.selectedPath
    git.getRepoForPath(path)
    .then (repo) ->
      file = repo.relativize(path)
      file = undefined if file is ''
      git.add(repo, {file}).then -> GitCommit(repo)
    .catch (error) ->
      console.log error
      notifier.addError 'There was an error executing Add + Commit'
  else
    notifier.addInfo "No file selected to add and commit"
