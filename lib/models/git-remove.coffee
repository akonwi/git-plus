git = require '../git'
ActivityLogger = require('../activity-logger').default
Repository = require('../repository').default
RemoveListView = require '../views/remove-list-view'

gitRemove = (repo, {showSelector}={}) ->
  cwd = repo.getWorkingDirectory()
  currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  if currentFile? and not showSelector
    if repo.isPathModified(currentFile) is false or window.confirm('Are you sure?')
      atom.workspace.getActivePaneItem().destroy()
      repoName = new Repository(repo).getName()
      git.cmd(['rm', '-f', '--ignore-unmatch', currentFile], {cwd})
      .then (data) -> ActivityLogger.record({repoName, message: "Remove '#{prettify data}'", output: data})
      .catch (data) -> ActivityLogger.record({repoName, message: "Remove '#{prettify data}'", output: data, failed: true})
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
