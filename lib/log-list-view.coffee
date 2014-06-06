{$$, BufferedProcess, SelectListView} = require 'atom'
OutputView = require './output-view'
StatusView = require './status-view'

module.exports =
class LogListView extends SelectListView
  initialize: (@data) ->
    super
    @addClass 'overlay from-top'
    @parseData()

  parseData: ->
    @data = @data.split("\n")
    items = for item in @data
      continue if not item?
      tmp = item.match /([\w\d]{7});\|(.*);\|(.*);\|(.*)/
      {hash: tmp?[1], author: tmp?[2], title: tmp?[3], time: tmp?[4]}
    @setItems items
    atom.workspaceView.append this
    @focusFilterEditor()

  getFilterKey: -> 'title'

  viewForItem: (commit) ->
    $$ ->
      @li =>
        @div class: 'text-highlight text-huge', commit.title
        @div class: '', "#{commit.hash} by #{commit.author}"
        @div class: 'text-info', commit.time

  confirmed: ({hash}) ->
    console.log hash
    @cancel()
