{$$, BufferedProcess, SelectListView} = require 'atom'

TagView = require './tag-view'
TagCreateView = require './tag-create-view'

module.exports =
class TagListView extends SelectListView

  initialize: (@data) ->
    super
    @addClass 'overlay from-top'
    @parseData()

  parseData: ->
    if @data.length > 0
      @data = @data.split("\n")[...-1]
      items = (
        for item in @data.reverse() when item != ''
          tmp = item.match /([\w\d-_/.]+)\s(.*)/
          {tag: tmp?[1], annotation: tmp?[2]}
      )
    else
      items = []

    items.push {tag: '+ Add Tag', annotation: 'Add a tag referencing the current commit.'}

    @setItems items
    atom.workspaceView.append this
    @focusFilterEditor()

  getFilterKey: -> 'tag'

  viewForItem: ({tag, annotation}) ->
    $$ ->
      @li =>
        @div class: 'text-highlight', tag
        @div class: 'text-warning', annotation

  confirmed: ({tag}) ->
    @cancel()
    if tag is '+ Add Tag'
      new TagCreateView()
    else
      new TagView(tag)
