{$, $$} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'
SelectListMultipleView = require './select-list-multiple-view'

module.exports =
class SelectStageFilesView extends SelectListMultipleView
  initialize: (@repo, items) ->
    super
    @selectedItems.push 'foobar' # hack to override super class behavior so ::completed will be called
    @show()
    @setItems items
    @focusFilterEditor()

  getFilterKey: -> 'path'

  addButtons: ->
    viewButton = $$ ->
      @div class: 'select-list-buttons', =>
        @div =>
          @button class: 'btn btn-error inline-block-tight btn-cancel-button', 'Cancel'
        @div =>
          @button class: 'btn btn-success inline-block-tight btn-apply-button', 'Apply'
    viewButton.appendTo(this)

    @on 'click', 'button', ({target}) =>
      @complete() if $(target).hasClass('btn-apply-button')
      @cancel() if $(target).hasClass('btn-cancel-button')

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @storeFocusedElement()

  cancelled: -> @hide()

  hide: -> @panel?.destroy()

  viewForItem: (item, matchedStr) ->
    classString = if item.staged then 'active' else ''
    $$ ->
      @li class: classString, =>
        @div class: 'pull-right', =>
          @span class: 'inline-block highlight', item.mode
        if matchedStr? then @raw(matchedStr) else @span item.path

  confirmed: (item, viewItem) ->
    item.staged = not item.staged
    viewItem.toggleClass('active')

  completed: (_) ->
    stage = @items.filter((item) -> item.staged).map ({path}) -> path
    unstage = @items.filter((item) -> not item.staged).map ({path}) -> path
    stagePromise = if stage.length > 0  then git.cmd(['add', '-f'].concat(stage), cwd: @repo.getWorkingDirectory())
    unstagePromise = if unstage.length > 0 then git.cmd(['reset', 'HEAD', '--'].concat(unstage), cwd: @repo.getWorkingDirectory())
    Promise.all([stagePromise, unstagePromise])
    .then (data) -> notifier.addSuccess 'Index updated successfully'
    .catch notifier.addError
    @cancel()
