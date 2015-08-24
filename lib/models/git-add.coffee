git = require '../git'

module.exports = (repo, {addAll}={}) ->
  if addAll
    file = null
  else
    file = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  git.add(repo, file: file)
