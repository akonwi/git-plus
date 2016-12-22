contextPackageFinder = require '../../context-package-finder'
git = require '../../git'
notifier = require '../../notifier'
GitCheckoutFile = require '../git-checkout-file'

module.exports = ->
  if path = contextPackageFinder.get()?.selectedPath
    git.getRepoForPath(path).then (repo) ->
      GitCheckoutFile repo, file: repo.relativize(path)
  else
    notifier.addInfo "No file selected to checkout"
