contextPackageFinder = require '../../context-package-finder'
git = require '../../git'
notifier = require '../../notifier'
GitCheckoutFile = require '../git-checkout-file'

module.exports = ->
  if path = contextPackageFinder.get()?.selectedPath
    git.getRepoForPath(path).then (repo) ->
      atom.confirm
        message: "Are you sure you want to reset #{repo.relativize(path)} to HEAD"
        buttons:
          Yes: -> GitCheckoutFile repo, file: repo.relativize(path)
          No:  ->
  else
    notifier.addInfo "No file selected to checkout"
