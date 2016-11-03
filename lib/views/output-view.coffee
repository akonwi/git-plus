AnsiToHtml = require 'ansi-to-html'
ansiToHtml = new AnsiToHtml()
{$, ScrollView} = require 'atom-space-pen-views'

defaultMessage = 'Nothing new to show'
module.exports =
  class OutputView extends ScrollView
    message: ''
    html: undefined

    @content: ->
      @div class: 'git-plus info-view', =>
        @pre class: 'output', defaultMessage

    initialize: ->
      super

    reset: ->
      @message = defaultMessage
      @html = undefined

    addLine: (line) ->
      @message = '' if @message is defaultMessage
      @message += line
      this

    setColorEncodedContent: (content) -> @html = ansiToHtml.toHtml content

    finish: ->
      output =  @find(".output")
      if @html
        output.html(@html)
      else
        output.text(@message)
      @show()
      @timeout = setTimeout =>
        @hide()
      , atom.config.get('git-plus.messageTimeout') * 1000

    toggle: ->
      clearTimeout @timeout if @timeout
      $.fn.toggle.call(this)
