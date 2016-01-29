git = require '../git'
LogListView = require '../views/log-list-view'
LogViewURI = 'atom://git-plus:log'

module.exports = (repo, {onlyCurrentFile}={}) ->
  atom.workspace.addOpener (uri) ->
    return new LogListView if uri is LogViewURI

  currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  atom.workspace.open(LogViewURI).then (view) ->
    if onlyCurrentFile
      view.currentFileLog(repo, currentFile)
    else
      view.branchLog repo
