{BufferedProcess} = require 'atom'
StatusView = require './status-view'

# if all param true, then 'git add .'
gitAdd = (all=false)->

  # pobetiger 2014/06/13
  # on v0.103.0, atom.project.getRepo() returns null
  # attempt to deref this obj will cause exception
  # modified to check before calling getWorkingDirectory()
  # otherwise we should use getPath()
  # but this might be a bug in atom itself (getRepo() not working?)
  # this work around will get add to work
  currentRepo = atom.project.getRepo()

  if (currentRepo)
    dir = atom.project.getRepo().getWorkingDirectory()
  else
    dir = atom.project.getPath()

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
