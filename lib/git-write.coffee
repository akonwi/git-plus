{BufferedProcess} = require 'atom'
StatusView = require './status-view'

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
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
  })

module.exports = gitWrite
