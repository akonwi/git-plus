{BufferedProcess} = require 'atom'

# if all param true, then 'git add .'
gitWrite = (all=false)->
  dir = atom.project.getRepo().getWorkingDirectory()
  currentFile = atom.workspace.getActiveEditor().getPath()
  toStage = if all then '.' else currentFile
  new BufferedProcess({
    command: 'git'
    args: ['add', toStage]
    options:
      cwd: dir
    stdout: (data) =>
      if data.toString().indexOf 'fatal:'
        alert data.toString()
  })

module.exports = gitWrite
