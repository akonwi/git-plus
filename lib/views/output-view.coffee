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
      @subscribe $(window), 'core:cancel', => @destroy()
      @panel ?= atom.workspace.addBottomPanel(item: this)

    addLine: (line) ->
      @message += line

    reset: ->
      @message = ''

    finish: ->
      @find(".output").append(@message)
      setTimeout =>
        @destroy()
      , atom.config.get('git-plus.messageTimeout') * 1000

    destroy: ->
      @panel.destroy()
      @unsubscribe()
