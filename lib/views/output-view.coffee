{$, ScrollView} = require 'atom-space-pen-views'

defaultMessage = 'Nothing new to show'
module.exports =
  class OutputView extends ScrollView
    message: ''
    wasOpenedManually: false

    @content: ->
      @div class: 'git-plus info-view', =>
        @pre class: 'output', defaultMessage

    initialize: ->
      super

    addLine: (line) ->
      @message = '' if @message is defaultMessage
      @message += line
      this

    reset: -> @message = defaultMessage

    finish: ->
      @find(".output").text(@message)
      @show()
      unless @wasOpenedManually
        @timeout = setTimeout =>
          @hide()
        , atom.config.get('git-plus.messageTimeout') * 1000

    toggle: ->
      clearTimeout @timeout if @timeout
      @wasOpenedManually = not @wasOpenedManually
      $.fn.toggle.call(this)
