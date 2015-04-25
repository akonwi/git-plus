git = require '../git'
LogListView = require '../views/log-list-view'
ViewUriLog = 'atom://git-plus:log'

gitLog = (onlyCurrentFile=false) ->
  currentFile = git.relativize(atom.workspace.getActiveTextEditor()?.getPath())

  atom.workspace.addOpener (filePath) ->
    return new LogListView() if filePath is ViewUriLog

  atom.workspace.open(ViewUriLog).done (logListView) ->
    if logListView instanceof LogListView
      if onlyCurrentFile
        logListView.currentFileLog(onlyCurrentFile, currentFile)
      else
        logListView.branchLog()

module.exports = gitLog
