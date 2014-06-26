git = require '../git'
StatusView = require '../views/status-view'
RemoveListView = require '../views/remove-list-view'

gitRemove = (showSelector=false) ->
  currentFile = git.relativize(atom.workspace.getActiveEditor()?.getPath())

  if currentFile? and not showSelector
    atom.workspaceView.getActiveView().remove()
    git.cmd
      args: ['rm', '-f', '--ignore-unmatch', currentFile],
      stdout: (data) ->  new StatusView(type: 'success', message: "Removed #{prettify data}")
  else
    git.cmd
      args: ['rm', '-r', '-n', '--ignore-unmatch', '-f', '*'],
      stdout: (data) -> new RemoveListView(prettify data)

# cut off rm '' around the filenames.
prettify = (data) ->
  data = data.match(/rm ('.*')/g)
  for file, i in data
    data[i] = file.match(/rm '(.*)'/)[1]

module.exports = gitRemove
