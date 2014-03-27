spawn = require('child_process').spawn
{Git} = require 'atom'
StatusView = require './status-view'

module.exports =
  statusView: null

  activate: (state) ->
    atom.workspaceView.command "git-plus:status", => @showStatus()

  deactivate: ->
    # @gitPlusView.destroy()

  serialize: ->
    # gitPlusViewState: @gitPlusView.serialize()

  showStatus: ->
    dir = atom.project.getRepo().getWorkingDirectory()
    ls = spawn 'ls', [], cwd: dir
    ls.stdout.on 'data', (data) =>
      @statusView = new StatusView()
        .find('div.message').html(data.toString())
