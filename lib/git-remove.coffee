{BufferedProcess} = require 'atom'
StatusView = require './status-view'
RemoveListView = require './remove-list-view'

gitRemove = (showSelector=false) ->
  dir = atom.project.getRepo().getWorkingDirectory()
  currentFile = atom.workspace.getActiveEditor()?.getPath()

  if currentFile? and not showSelector
    new BufferedProcess({
    command: 'git'
    args: ['rm', '-f', '--ignore-unmatch', currentFile]
    options:
      cwd: dir
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
    stdout: (data) ->
      new StatusView(type: 'success', message: "Removed #{prettify data}")
    })
  else
    new BufferedProcess({
      command: 'git'
      args: ['rm', '-r', '-n', '--ignore-unmatch', '-f', '*']
      options:
        cwd: dir
      stdout: (data) ->
        new RemoveListView(prettify data)
      stderr: (data) ->
        new StatusView(type: 'alert', message: data.toString())
    })

# cut off rm '' around the filenames.
prettify = (data) ->
  data = data.match(/rm '(.*)'/g)
  for file, i in data
    data[i] = file.match(/rm '(.*)'/)[1]

module.exports = gitRemove
