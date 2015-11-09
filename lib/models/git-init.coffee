git = require '../git'
ProjectsListView = require '../views/projects-list-view'
notifier = require '../notifier'

init = (path) ->
  git.cmd(['init'], cwd: path)
  .then (data) ->
    notifier.addSuccess data
    atom.project.setPaths(atom.project.getPaths())

module.exports = ->
  currentFile = atom.workspace.getActiveTextEditor()?.getPath()
  if not currentFile and atom.project.getPaths().length > 1
    new ProjectsListView().result.then (path) -> init(path)
  else
    init(atom.project.getPaths()[0])
