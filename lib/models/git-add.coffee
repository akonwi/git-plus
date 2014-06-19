git = require '../git'
StatusView = require '../views/status-view'

gitAdd = (addAll=false) ->
  file = ''
  dir = null
  if not addAll
    filePath = atom.workspace.getActiveEditor()?.getPath()
    if submodule = atom.project.getRepo().repo.submoduleForPath(filePath)
      file = submodule.relativize(filePath)
      dir = submodule.getWorkingDirectory()
    else
      file = atom.project.relativize(filePath)
  else
    file = null

  git.cmd
    args: ['add', '--all', file ? '.']
    options:
      cwd: dir ? git.dir()
    exit: (code) -> new StatusView(type: 'success', message: "Added #{file ? 'all files'}")

module.exports = gitAdd
