fs = require 'fs-plus'
{$$, SelectListView} = require 'atom-space-pen-views'
git = require('../git-es').default
notifier = require '../notifier'
ActivityLogger = require('../activity-logger').default
Repository = require('../repository').default

module.exports =
  class ListView extends SelectListView
    initialize: (@repo, @data) ->
      super
      @show()
      @parseData()

    parseData: ->
      items = @data.split("\n")
      branches = []
      for item in items
        item = item.replace(/\s/g, '')
        unless item is ''
          branches.push {name: item}
      @setItems branches
      @focusFilterEditor()

    getFilterKey: -> 'name'

    show: ->
      @panel ?= atom.workspace.addModalPanel(item: this)
      @panel.show()
      @storeFocusedElement()

    cancelled: -> @hide()

    hide: ->
      @panel?.destroy()

    viewForItem: ({name}) ->
      current = false
      if name.startsWith "*"
        name = name.slice(1)
        current = true
      $$ ->
        @li name, =>
          @div class: 'pull-right', =>
            @span('Current') if current

    confirmed: ({name}) ->
      @rebase name.match(/\*?(.*)/)[1]
      @cancel()

    rebase: (branch) ->
      git(['rebase', branch], cwd: @repo.getWorkingDirectory())
      .then (result) =>
        repoName = new Repository(@repo).getName()
        ActivityLogger.record(Object.assign({repoName, message: "rebase branch '#{branch}'"}, result))
        atom.workspace.getTextEditors().forEach (editor) ->
          fs.exists editor.getPath(), (exist) -> editor.destroy() if not exist
        git.refresh @repo
