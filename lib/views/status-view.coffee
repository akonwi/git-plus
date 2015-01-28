{Subscriber} = require 'emissary'
{$, View} = require 'atom-space-pen-views'

module.exports =
  class StatusView extends View
    Subscriber.includeInto(this)

    @content = (params) ->
      @div class: 'git-plus overlay from-bottom', =>
        @div class: "#{params.type} message", params.message

    initialize: ->
      @subscribe $(window), 'core:cancel', => @detach()
      atom.workspace.addBottomPanel(item: this)
      setTimeout =>
        @detach()
      , atom.config.get('git-plus.messageTimeout') * 1000

    detach: ->
      super
      @unsubscribe()
