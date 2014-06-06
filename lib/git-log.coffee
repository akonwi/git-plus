{BufferedProcess} = require 'atom'
LogListView = require './log-list-view'
StatusView = require './status-view'

dir = ->
  atom.project.getRepo().getWorkingDirectory()

gitLog = ->
  new BufferedProcess
    command: 'git'
    args: ['log', '--pretty="%h;|%aN <%aE>;|%s;|%ar (%aD)"', '-s', '-n25']
    options:
      cwd: dir
    stdout: (data) ->
      new LogListView(data)
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())

module.exports = gitLog
