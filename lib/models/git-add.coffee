git = require '../git'

module.exports = (repo, {addAll}={}) ->
  if addAll
    git.add repo
  else
    file = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
    git.add(repo, file: file)
