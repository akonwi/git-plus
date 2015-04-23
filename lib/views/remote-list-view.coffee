{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'

git = require '../git'
OutputView = require './output-view'
PullBranchListView = require './pull-branch-list-view'

module.exports =
class ListView extends SelectListView
  initialize: (@data, @mode, @setUpstream=false, @tag='') ->
    super
    @show()
    @parseData()

  parseData: ->
    items = @data.split("\n")
    remotes = []
    for item in items
      remotes.push {name: item} unless item is ''
    if remotes.length is 1
      @confirmed remotes[0]
    else
      @setItems remotes
      @focusFilterEditor()

  getFilterKey: -> 'name'

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

  cancelled: -> @hide()

  hide: ->
    @panel?.hide()

  viewForItem: ({name}) ->
    $$ ->
      @li name

  confirmed: ({name}) ->
    if @mode is 'pull'
      new PullBranchListView(name)
    else
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
