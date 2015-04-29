_ = require 'underscore-plus'
{$, $$, SelectListView} = require 'atom-space-pen-views'
git = require '../git'
GitPlusCommands = require '../git-plus-commands'
fuzzy = require('../models/fuzzy').filter

module.exports =
class GitPaletteView extends SelectListView

  initialize: ->
    super
    @addClass('git-palette')
    @toggle()

  getFilterKey: ->
    'description'

  cancelled: -> @hide()

  toggle: ->
    if @panel?.isVisible()
      @cancel()
    else
      @show()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)

    @storeFocusedElement()

    if @previouslyFocusedElement[0] and @previouslyFocusedElement[0] isnt document.body
      @commandElement = @previouslyFocusedElement
    else
      @commandElement = atom.views.getView(atom.workspace)
    @keyBindings = atom.keymaps.findKeyBindings(target: @commandElement[0])

    GitPlusCommands()
      .catch =>
        (commands = []).push { name: 'git-plus:init', description: 'Init', func: -> GitInit() }
        @setItems(commands)
        @panel.show()
        @focusFilterEditor()
      .then (commands) =>
        commands = commands.map (c) -> { name: c[0], description: c[1], func: c[2] }
        commands = _.sortBy(commands, 'name')
        @setItems(commands)
        @panel.show()
        @focusFilterEditor()

  populateList: ->
    return unless @items?

    filterQuery = @getFilterQuery()
    if filterQuery.length
      options =
        pre: '<span class="text-warning" style="font-weight:bold">'
        post: "</span>"
        extract: (el) => if @getFilterKey()? then el[@getFilterKey()] else el
      filteredItems = fuzzy(filterQuery, @items, options)
    else
      filteredItems = @items

    @list.empty()
    if filteredItems.length
      @setError(null)
      for i in [0...Math.min(filteredItems.length, @maxItems)]
        item = filteredItems[i].original ? filteredItems[i]
        itemView = $(@viewForItem(item, filteredItems[i].string ? null))
        itemView.data('select-list-item', item)
        @list.append(itemView)

      @selectItemView(@list.find('li:first'))
    else
      @setError(@getEmptyMessage(@items.length, filteredItems.length))

  hide: ->
    @panel?.destroy()

  viewForItem: ({name, description}, matchedStr) ->
    $$ ->
      @li class: 'command', 'data-command-name': name, =>
        if matchedStr? then @raw(matchedStr) else @span description

  confirmed: ({func}) ->
    @cancel()
    func()
