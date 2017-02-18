contextPackageFinder = require '../../context-package-finder'
git = require '../../git'
notifier = require '../../notifier'
GitPush = require '../git-push'

module.exports = (options={})->
  if path = contextPackageFinder.get()?.selectedPath
    git.getRepoForPath(path).then (repo) -> GitPush(repo, options)
  else
    notifier.addInfo "No repository found"
