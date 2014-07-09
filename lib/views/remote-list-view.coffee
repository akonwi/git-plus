{$$, BufferedProcess, SelectListView} = require 'atom'

git = require '../git'
OutputView = require './output-view'

module.exports =
class ListView extends SelectListView
  initialize: (@data, @mode, @setUpstream=false, @tag='') ->
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
    view = new OutputView()
    git.cmd
      args: [@mode, remote, @tag]
      stdout: (data) -> view.addLine(data.toString())
      stderr: (data) -> view.addLine(data.toString())
      exit: (code) =>
        if code is 128
          view.reset()
          git.cmd
            args: [@mode, '-u', remote, 'HEAD']
            stdout: (data) -> view.addLine(data.toString())
            stderr: (data) -> view.addLine(data.toString())
            exit: (code) -> view.finish()
        else
          view.finish()
