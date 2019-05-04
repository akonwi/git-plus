_ = require 'underscore-plus'
{$, $$, SelectListView} = require 'atom-space-pen-views'
{getRepoCommands} = require '../commands'
fuzzyFilter = require('fuzzaldrin').filter
CommandsKeystrokeHumanizer = require('../command-keystroke-humanizer')()
memoizeOne = require('memoize-one');

getCommandsWithDisplayNames = memoizeOne(
  (commands) ->
    commands.map ({id, displayName, run}) ->
      { id, run, displayName: displayName || _.humanizeEventName(id) } 
)

module.exports =
class GitPaletteView extends SelectListView

  initialize: ->
    super
    @addClass('git-palette')
    @toggle()

  getFilterKey: ->
    'displayName'

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

    commands = _.sortBy getCommandsWithDisplayNames(getRepoCommands()), 'displayName'
    @keystrokes = CommandsKeystrokeHumanizer.get(commands)
    @setItems(commands)
    @panel.show()
    @focusFilterEditor()

  populateList: ->
    return unless @items?

    filterQuery = @getFilterQuery()
    if filterQuery.length
      options =
        key: @getFilterKey()
      filteredItems = fuzzyFilter(@items, filterQuery, options)
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

  viewForItem: ({id, displayName}, matchedStr) ->
    keystroke = @keystrokes["git-plus:#{id}"]
    $$ ->
      @li class: 'command', 'data-command-name': id, =>
        if matchedStr? then @raw(matchedStr)
        else
          @span displayName
          if keystroke?
            @div class: 'pull-right', =>
              @kbd class: 'key-binding', keystroke

  confirmed: ({func}) ->
    @cancel()
    func()
