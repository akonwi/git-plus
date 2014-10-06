{Subscriber} = require 'emissary'
{$, ScrollView} = require 'atom'

module.exports =
  class OutputView extends ScrollView
    Subscriber.includeInto (this)

    message: ''

    @content: ->
      @div class: 'git-plus info-view', =>
        @pre class: 'output'

    initialize: ->
      super
      atom.workspaceView.appendToBottom(this)
      @subscribe $(window), 'core:cancel', => @detach()

    addLine: (line) ->
      @message += line

    reset: ->
      @message = ''

    finish: ->
      @find(".output").append(@message)
      setTimeout =>
        @detach()
      , atom.config.get('git-plus.messageTimeout') * 1000

    detach: ->
      super
      @unsubscribe()
