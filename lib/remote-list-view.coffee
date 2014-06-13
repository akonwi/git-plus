{$$, BufferedProcess, SelectListView} = require 'atom'
OutputView = require './output-view'
StatusView = require './status-view'

module.exports =
class ListView extends SelectListView
  initialize: (@data, @mode) ->
    super
    @addClass 'overlay from-top'
    @parseData()

  parseData: ->
    items = @data.split("\n")
    remotes = []
    for item in items
      remotes.push {name: item} unless item is ''
    if remotes.length is 1
      @execute remotes[0].name
    else
      @setItems remotes
      atom.workspaceView.append this
      @focusFilterEditor()

  getFilterKey: -> 'name'

  viewForItem: ({name}) ->
    $$ ->
      @li name

  confirmed: ({name}) ->
    @execute name
    @cancel()

  execute: (remote) ->
    dir = atom.project.getRepo()?.getWorkingDirectory() ? atom.project.getPath()
    view = new OutputView()
    new BufferedProcess
      command: 'git'
      args: [@mode, remote]
      options:
        cwd: dir
      stdout: (data) ->
        view.addLine(data.toString())
      stderr: (data) ->
        view.addLine(data.toString())
      exit: (code) ->
        view.finish()
