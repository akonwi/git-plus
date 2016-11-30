contextPackageFinder = require '../../context-package-finder'
notifier = require '../../notifier'

module.exports = (repo, contextCommandMap) ->
  if path = contextPackageFinder.get()?.selectedPath
    if path is repo.getWorkingDirectory()
      file = path
    else
      file = repo.relativize(path)
    file = undefined if file is ''
    contextCommandMap 'diff', {repo, file}
  else
    notifier.addInfo "No file selected to diff"
