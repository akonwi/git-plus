git = require '../git'
StatusView = require '../views/status-view'

gitAdd = (addAll=false) ->
  if not addAll
    file = git.relativize(atom.workspace.getActiveEditor()?.getPath())
  else
    file = null

  git.add(file: file)

module.exports = gitAdd
