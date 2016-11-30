contextPackageFinder = require '../../context-package-finder'
notifier = require '../../notifier'
GitCheckoutFile = require '../git-checkout-file'

module.exports = (repo) ->
  if path = contextPackageFinder.get()?.selectedPath
    GitCheckoutFile repo, file: repo.relativize(path)
  else
    notifier.addInfo "No file selected to checkout"
