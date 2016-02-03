git = require '../git'
notifier = require '../notifier'
RemoveListView = require '../views/remove-list-view'

gitRemove = (repo, {showSelector}={}) ->
  cwd = repo.getWorkingDirectory()
  currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  if currentFile? and not showSelector
    if repo.isPathModified(currentFile) is false or window.confirm('Are you sure?')
      atom.workspace.getActivePaneItem().destroy()
      git.cmd(['rm', '-f', '--ignore-unmatch', currentFile], {cwd})
      .then (data) -> notifier.addSuccess("Removed #{prettify data}")
  else
    git.cmd(['rm', '-r', '-n', '--ignore-unmatch', '-f', '*'], {cwd})
    .then (data) -> new RemoveListView(repo, prettify(data))

prettify = (data) ->
  data = data.match(/rm ('.*')/g)
  if data
    for file, i in data
      data[i] = file.match(/rm '(.*)'/)[1]
  else
    data

module.exports = gitRemove
