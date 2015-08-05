{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
  class OutputView extends ScrollView
    message: ''

    @content: ->
      @div class: 'git-plus info-view', =>
        @pre class: 'output'

    initialize: ->
      super

    addLine: (line) ->
      @message += line

    reset: ->
      @message = ''

    finish: ->
      @panel ?= atom.workspace.addBottomPanel(item: this)
      @find(".output").append(@message)
      setTimeout =>
        @destroy()
      , atom.config.get('git-plus.messageTimeout') * 1000

    destroy: ->
      @panel?.destroy()
