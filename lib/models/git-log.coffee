git = require '../git'
LogListView = require '../views/log-list-view2'
ViewUriLog = 'atom://git-plus:log'

amountOfCommitsToShow = ->
  atom.config.get('git-plus.amountOfCommitsToShow')

gitLog = (onlyCurrentFile=false) ->
  atom.workspace.addOpener (filePath) ->
    return new LogListView() if filePath is ViewUriLog

  currentFile = git.relativize(atom.workspace.getActiveTextEditor()?.getPath())

  # git log --graph --oneline --decorate --date=relative --all

  # args = ['log', "--pretty='%h;|%H;|%aN <%aE>;|%s;|%ar (%aD)_.;._'", '-s', "-n#{amountOfCommitsToShow()}"]
  args = ['log', "--pretty=%h;|%H;|%aN;|%aE;|%D %s;|%ai_.;._", '-s', '-n 100']
  # args = ['log', '--graph', '--oneline', '--decorate', '--date=relative', '--all']
  args.push currentFile if onlyCurrentFile and currentFile?
  git.cmd
    args: args
    options:
      cwd: git.dir(false)
    stdout: (data) ->
      atom.workspace.open(ViewUriLog).done (logListView) ->
        if logListView instanceof LogListView
          logListView.parseData(data)
          logListView.renderLog()
      # new LogListView(data, onlyCurrentFile)

module.exports = gitLog
