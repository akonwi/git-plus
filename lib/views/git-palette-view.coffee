_ = require 'underscore-plus'
{$, $$, SelectListView} = require 'atom'
git = require '../git'
GitPlusCommands = require '../git-plus-commands'

module.exports =
class GitPaletteView extends SelectListView

  initialize: ->
    git.refresh() if atom.project.getRepo()?
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

  viewForItem: ({name, description}) ->
    $$ ->
      @li class: 'command', 'data-command-name': name, =>
        @span description, title: name

  confirmed: ({func}) ->
    func()
