git = require '../git'
notifier = require '../notifier'
RemoveListView = require '../views/remove-list-view'

gitRemove = (repo, {showSelector}={}) ->
  currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())

  if currentFile? and not showSelector
    if window.confirm 'Are you sure?'
      atom.workspace.getActivePaneItem().destroy()
      git.cmd
        args: ['rm', '-f', '--ignore-unmatch', currentFile]
        cwd: repo.getWorkingDirectory()
        stdout: (data) ->
          notifier.addSuccess("Removed #{prettify data}")
  else
    git.cmd
      args: ['rm', '-r', '-n', '--ignore-unmatch', '-f', '*']
      cwd: repo.getWorkingDirectory()
      stdout: (data) -> new RemoveListView(repo, prettify(data))

# cut off rm '' around the filenames.
prettify = (data) ->
  data = data.match(/rm ('.*')/g)
  if data
    for file, i in data
      data[i] = file.match(/rm '(.*)'/)[1]
  else
    data

module.exports = gitRemove
