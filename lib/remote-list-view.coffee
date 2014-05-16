{$$, BufferedProcess, SelectListView} = require 'atom'
OutputView = require './output-view'
StatusView = require './status-view'

module.exports =
class ListView extends SelectListView
  initialize: (@data) ->
    super
    @addClass 'overlay from-top'
    @parseData()

  parseData: ->
    items = @data.split("\n")
    remotes = []
    for item in items
      remotes.push {name: item} unless item is ''
    if remotes.length is 1
      @pushTo remotes[0].name
    else
      @setItems remotes
      atom.workspaceView.append this
      @focusFilterEditor()

  getFilterKey: -> 'name'

  viewForItem: ({name}) ->
    $$ ->
      @li name

  confirmed: ({name}) ->
    @pushTo name
    @cancel()

  pushTo: (remote) ->
    dir = atom.project.getRepo().getWorkingDirectory()
    view = new OutputView()
    new BufferedProcess
      command: 'git'
      args: ['push', remote]
      options:
        cwd: dir
      stdout: (data) ->
        view.addLine(data.toString())
      stderr: (data) ->
        view.addLine(data.toString())
      exit: (code) ->
        view.finish()
