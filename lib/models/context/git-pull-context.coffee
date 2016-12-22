contextPackageFinder = require '../../context-package-finder'
git = require '../../git'
notifier = require '../../notifier'
GitPull = require '../git-pull'

module.exports = (options={})->
  if path = contextPackageFinder.get()?.selectedPath
    git.getRepoForPath(path).then (repo) -> GitPull(repo, options)
  else
    notifier.addInfo "No repository found"
