git = require '../git'
LogListView = require '../views/log-list-view'

amountOfCommitsToShow = ->
  atom.config.get('git-plus.amountOfCommitsToShow')

gitLog = (onlyCurrentFile=false) ->
  currentFile = git.relativize(atom.workspace.getActiveTextEditor()?.getPath())

  args = ['log', "--pretty='%h;|%aN <%aE>;|%s;|%ar (%aD)'", '-s', "-n#{amountOfCommitsToShow()}"]
  args.push currentFile if onlyCurrentFile and currentFile?
  git.dir(false).then (dir) ->
    git.cmd
      args: args
      options:
        cwd: dir
      stdout: (data) -> new LogListView(data, onlyCurrentFile)

module.exports = gitLog
