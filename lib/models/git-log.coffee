git = require '../git'
LogListView = require '../views/log-list-view'
ViewUriLog = 'atom://git-plus:log'

amountOfCommitsToShow = ->
  atom.config.get('git-plus.amountOfCommitsToShow')

gitLog = (repo, {onlyCurrentFile}={}) ->
  # opener doesn't get overwritten with a new instance of LogListView
  atom.workspace.addOpener (filePath) ->
    return new LogListView if filePath is ViewUriLog

  atom.workspace.open(ViewUriLog).done (view) ->
    if view instanceof LogListView
      view.setRepo repo
      if onlyCurrentFile
        currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
        view.currentFileLog(onlyCurrentFile, currentFile)
      else
        view.branchLog()

module.exports = gitLog
