{Subscriber} = require 'emissary'
{$, View} = require 'atom-space-pen-views'

module.exports =
  class StatusView extends View
    Subscriber.includeInto(this)

    @content = (params) ->
      @div class: 'git-plus', =>
        @div class: "#{params.type} message", params.message

    initialize: ->
      @subscribe $(window), 'core:cancel', => @destroy()
      @panel ?= atom.workspace.addBottomPanel(item: this)
      setTimeout =>
        @destroy()
      , atom.config.get('git-plus.messageTimeout') * 1000

    destroy: ->
      @panel.destroy()
      @unsubscribe()
