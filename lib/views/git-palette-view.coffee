_ = require 'underscore-plus'
{$, $$, SelectListView} = require 'atom'
git = require '../git'
GitPlusCommands = require '../git-plus-commands'
fuzzy = require('../models/fuzzy').filter

module.exports =
class GitPaletteView extends SelectListView

  initialize: ->
    super
    @addClass('git-palette overlay from-top')
    @toggle()

  getFilterKey: ->
    'description'

  toggle: ->
    if @hasParent()
      @cancel()
    else
      @attach()

  attach: ->
    @storeFocusedElement()

    if @previouslyFocusedElement[0] and @previouslyFocusedElement[0] isnt document.body
      @commandElement = @previouslyFocusedElement
    else
      @commandElement = atom.workspaceView
    @keyBindings = atom.keymap.findKeyBindings(target: @commandElement[0])

    commands = []
    for command in GitPlusCommands()
      commands.push({name: command[0], description: command[1], func: command[2]})
    commands = _.sortBy(commands, 'name')
    @setItems(commands)

    atom.workspaceView.append(this)
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

  viewForItem: ({name, description}, matchedStr) ->
    $$ ->
      @li class: 'command', 'data-command-name': name, =>
        if matchedStr? then @raw(matchedStr) else @span description

  confirmed: ({func}) ->
    @cancel()
    func()
