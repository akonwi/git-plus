{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
  class OutputView extends ScrollView
    message: ''

    @content: ->
      @div class: 'git-plus info-view', =>
        @pre class: 'output'

    initialize: ->
      super
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
      @panel?.destroy()
