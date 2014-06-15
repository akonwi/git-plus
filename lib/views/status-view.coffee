{Subscriber} = require 'emissary'
{$, View} = require 'atom'

module.exports =
  class StatusView extends View
    Subscriber.includeInto(this)

    @content = (params) ->
      @div class: 'git-plus overlay from-bottom', =>
        @div class: "#{params.type} message", params.message

    initialize: ->
      @subscribe $(window), 'core:cancel', => @detach()
      atom.workspaceView.append(this)
      setTimeout =>
        @detach()
      , 10000

    detach: ->
      super
      @unsubscribe()
