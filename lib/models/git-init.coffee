git = require '../git'
ProjectsListView = require '../views/projects-list-view'
StatusView = require '../views/status-view'

gitInit = ->
  currentFile = atom.workspace.getActiveTextEditor()?.getPath()
  if not currentFile and atom.project.getPaths().length > 1
    promise = new ProjectsListView().result.then (path) ->
      git.cmd
        args: ['init']
        cwd: path
        stdout: (data) ->
          new StatusView(type: 'success', message: data)
          atom.project.setPath(path)
  else
    path = atom.project.getPaths()[0]
    git.cmd
      args: ['init']
      cwd: path
      stdout: (data) ->
        new StatusView(type: 'success', message: data)
        atom.project.setPath(path)

module.exports = gitInit
