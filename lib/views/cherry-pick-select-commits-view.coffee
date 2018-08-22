{$, $$} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'
ActivityLogger = require('../activity-logger').default
Repository = require('../repository').default
SelectListMultipleView = require './select-list-multiple-view'

module.exports =
class CherryPickSelectCommits extends SelectListMultipleView

  initialize: (@repo, data) ->
    super
    @show()
    @setItems(
      for item in data
        item = item.split('\n')
        {hash: item[0], author: item[1], time: item[2], subject: item[3]}
    )
    @focusFilterEditor()

  getFilterKey: -> 'hash'

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

  hide: -> @panel?.destroy()

  viewForItem: (item, matchedStr) ->
    $$ ->
      @li =>
        @div class: 'text-highlight inline-block pull-right', style: 'font-family: monospace', =>
          if matchedStr? then @raw(matchedStr) else @span item.hash
        @div class: 'text-info', "#{item.author}, #{item.time}"
        @div class: 'text-warning', item.subject

  completed: (items) ->
    @cancel()
    commits = items.map (item) -> item.hash
    message =  """cherry pick commits: #{commits.join(' ')}"""
    repoName = new Repository(@repo).getName()
    git.cmd(['cherry-pick'].concat(commits), cwd: @repo.getWorkingDirectory())
    .then (msg) ->
      notifier.addSuccess msg
      ActivityLogger.record({repoName, message, output: msg})
    .catch (msg) ->
      notifier.addError msg
      ActivityLogger.record({repoName, message, output: msg, failed: true})
