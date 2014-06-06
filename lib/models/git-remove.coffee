git = require '../git'
StatusView = require '../views/status-view'
RemoveListView = require '../views/remove-list-view'

gitRemove = (showSelector=false) ->
  currentFile = atom.project.getRepo().relativize atom.workspace.getActiveEditor()?.getPath()

  if currentFile? and not showSelector
    atom.workspaceView.getActiveView().remove()
    git(
      ['rm', '-f', '--ignore-unmatch', currentFile],
      (data) ->  new StatusView(type: 'success', message: "Removed #{prettify data}")
    )
  else
    git(
      ['rm', '-r', '-n', '--ignore-unmatch', '-f', '*'],
      (data) -> new RemoveListView(prettify data)
    )

# cut off rm '' around the filenames.
prettify = (data) ->
  data = data.match(/rm ('.*')/g)
  for file, i in data
    data[i] = file.match(/rm '(.*)'/)[1]

module.exports = gitRemove
