{BufferedProcess} = require 'atom'
StatusView = require './status-view'

# if all param true, then 'git add .'
gitAdd = (all=false)->
  dir = atom.project.getRepo().getWorkingDirectory()
  currentFile = atom.workspace.getActiveEditor()?.getPath()
  toStage = if all then '.' else currentFile
  if (toStage?)
    new BufferedProcess({
      command: 'git'
      args: ['add', '--all', toStage]
      options:
        cwd: dir
      stderr: (data) ->
        new StatusView(type: 'alert', message: data.toString())
      exit: (data) ->
        file = if toStage is '.' then 'all files' else prettify(dir, toStage)
        new StatusView(type: 'success', message: "Added #{file}")
    })
  else
    new StatusView(type: 'alert', message: "I don't know which file(s) to add!")

# only show filepaths inside the project
prettify = (dir, file) ->
  i = dir.lastIndexOf('/')
  root = dir.slice(i + 1)
  path = file.slice(i + root.length + 2)

module.exports = gitAdd
