contextPackageFinder = require '../../context-package-finder'
notifier = require '../../notifier'

module.exports = (repo, contextCommandMap) ->
  if path = contextPackageFinder.get()?.selectedPath
    file = repo.relativize(path)
    contextCommandMap 'checkout-file', {repo, file}
  else
    notifier.addInfo "No file selected to checkout"
