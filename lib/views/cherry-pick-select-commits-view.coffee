{$, $$} = require 'atom-space-pen-views'

git = require '../git'
OutputView = require './output-view'
StatusView = require './status-view'
SelectListMultipleView = require './select-list-multiple-view'

module.exports =
class CherryPickSelectCommits extends SelectListMultipleView

  initialize: (data) ->
    super
    @show()
    @setItems(
      for item in data
        item = item.split('\n')
        {hash: item[0], author: item[1], time: item[2], subject: item[3]}
    )
    @focusFilterEditor()

  getFilterKey: ->
    'hash'

  addButtons: ->
    viewButton = $$ ->
      @div class: 'buttons', =>
        @span class: 'pull-left', =>
          @button class: 'btn btn-error inline-block-tight btn-cancel-button', 'Cancel'
        @span class: 'pull-right', =>
          @button class: 'btn btn-success inline-block-tight btn-pick-button', 'Cherry-Pick!'
    viewButton.appendTo(this)

    @on 'click', 'button', ({target}) =>
      @complete() if $(target).hasClass('btn-pick-button')
      @cancel() if $(target).hasClass('btn-cancel-button')

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

  cancelled: -> @hide()

  hide: ->
    @panel?.hide()

  viewForItem: (item, matchedStr) ->
    $$ ->
      @li =>
        @div class: 'text-highlight inline-block pull-right', style: 'font-family: monospace', =>
          if matchedStr? then @raw(matchedStr) else @span item.hash
        @div class: 'text-info', "#{item.author}, #{item.time}"
        @div class: 'text-warning', item.subject

  completed: (items) ->
    @cancel()
    commits = (item.hash for item in items)
    git.cmd
      args: ['cherry-pick'].concat(commits),
      stdout: (data) ->
        new StatusView(type: 'success', message: data)
