{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'

TagView = require './tag-view'
TagCreateView = require './tag-create-view'

module.exports =
class TagListView extends SelectListView

  initialize: (@repo, @data='') ->
    super
    @show()
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
    @focusFilterEditor()

  getFilterKey: -> 'tag'

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @storeFocusedElement()

  cancelled: -> @hide()

  hide: -> @panel?.destroy()

  viewForItem: ({tag, annotation}) ->
    $$ ->
      @li =>
        @div class: 'text-highlight', tag
        @div class: 'text-warning', annotation

  confirmed: ({tag}) ->
    @cancel()
    if tag is '+ Add Tag'
      new TagCreateView(@repo)
    else
      new TagView(@repo, tag)
