contextPackageFinder = require '../context-package-finder'
notifier = require '../notifier'

module.exports = (repo, contextCommandMap) ->
  if path = contextPackageFinder.get()?.selectedPath
    file = repo.relativize(path)
    file = undefined if file is ''
    contextCommandMap 'add', {repo: repo, file}
  else
    notifier.addInfo "No file selected to add"
