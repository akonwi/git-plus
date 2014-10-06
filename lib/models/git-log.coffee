git = require '../git'
LogListView = require '../views/log-list-view'

currentFile = ->
  atom.project.relativize atom.workspace.getActiveEditor()?.getPath()

amountOfCommitsToShow = ->
  atom.config.getPositiveInt('git-plus.amountOfCommitsToShow') ? (atom.config.getDefault 'git-plus.amountOfCommitsToShow')

gitLog = (onlyCurrentFile=false) ->
  args = ['log', "--pretty='%h;|%aN <%aE>;|%s;|%ar (%aD)'", '-s', "-n#{amountOfCommitsToShow()}"]
  args.push currentFile() if onlyCurrentFile and currentFile()?
  git.cmd
    args: args
    options:
      cwd: git.dir(false)
    stdout: (data) -> new LogListView(data, onlyCurrentFile)

module.exports = gitLog
