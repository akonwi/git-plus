git = require '../git'
StatusView = require '../views/status-view'

# if all param true, then 'git add .'
gitAdd = (all=false) ->
  dir = atom.project.getRepo().getWorkingDirectory()
  currentFile = atom.project.getRepo().relativize atom.workspace.getActiveEditor()?.getPath()
  toStage = if all then '.' else currentFile
  if (toStage?)
    git(
      ['add', '--all', toStage],
      null,
      (data) ->
        file = if toStage is '.' then 'all files' else prettify(dir, toStage)
        new StatusView(type: 'success', message: "Added #{file}")
    )
  else
    new StatusView(type: 'alert', message: "I don't know which file(s) to add!")

# only show filepaths inside the project
prettify = (dir, file) ->
  i = dir.lastIndexOf('/')
  root = dir.slice(i + 1)
  path = file.slice(i + root.length + 2)

module.exports = gitAdd
