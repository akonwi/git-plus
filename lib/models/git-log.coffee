git = require '../git'
LogListView = require '../views/log-list-view'
ViewUriLog = 'atom://git-plus:log'

amountOfCommitsToShow = ->
  atom.config.get('git-plus.amountOfCommitsToShow')

gitLog = (repo, {onlyCurrentFile}={}) ->
  currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  atom.workspace.addOpener (filePath) ->
    new LogListView(repo) if filePath is ViewUriLog

  atom.workspace.open(ViewUriLog).done (logListView) ->
    if logListView instanceof LogListView
      if onlyCurrentFile
        logListView.currentFileLog(onlyCurrentFile, currentFile)
      else
        logListView.branchLog()

module.exports = gitLog
