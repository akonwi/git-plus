git = require '../git'

gitAdd = (repo, {addAll}={}) ->
  if not addAll
    file = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  else
    file = null

  git.add(repo, file: file)

module.exports = gitAdd
