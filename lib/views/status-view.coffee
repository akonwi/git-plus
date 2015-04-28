{$, View} = require 'atom-space-pen-views'

module.exports =
  class StatusView extends View
    @content = (params) ->
      @div class: 'git-plus', =>
        @div class: "#{params.type} message", params.message

    initialize: ->
      @panel ?= atom.workspace.addBottomPanel(item: this)
      setTimeout =>
        @destroy()
      , atom.config.get('git-plus.messageTimeout') * 1000

    destroy: ->
      @panel?.destroy()
