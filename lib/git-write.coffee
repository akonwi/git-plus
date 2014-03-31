{BufferedProcess} = require 'atom'

gitWrite = (all=false)->
  dir = atom.project.getRepo().getWorkingDirectory()
  currentFile = atom.workspace.getActiveEditor().getPath()
  toStage = if all then '.' else currentFile
  alert toStage
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
