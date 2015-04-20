git = require '../git'
LogListView = require '../views/log-list-view'

amountOfCommitsToShow = ->
  atom.config.get('git-plus.amountOfCommitsToShow')

gitLog = (repo, {onlyCurrentFile}={}) ->
  currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())

  args = ['log', "--pretty='%h;|%aN <%aE>;|%s;|%ar (%aD)'", '-s', "-n#{amountOfCommitsToShow()}"]
  args.push currentFile if onlyCurrentFile and currentFile?
  git.cmd
    args: args
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> new LogListView(data, onlyCurrentFile)
    exit: -> repo.destroy() if repo.destroyable

module.exports = gitLog
