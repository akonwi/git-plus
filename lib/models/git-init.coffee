git = require '../git'
ProjectsListView = require '../views/projects-list-view'
notifier = require '../notifier'

gitInit = ->
  currentFile = atom.workspace.getActiveTextEditor()?.getPath()
  if not currentFile and atom.project.getPaths().length > 1
    promise = new ProjectsListView().result.then (path) -> init(path)
  else
    init(atom.project.getPaths()[0])

init = (path) ->
  git.cmd
    args: ['init']
    cwd: path
    stdout: (data) ->
      notifier.addSuccess data
      atom.project.setPaths([path])

module.exports = gitInit
