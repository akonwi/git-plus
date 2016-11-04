AnsiToHtml = require 'ansi-to-html'
ansiToHtml = new AnsiToHtml()
{$, ScrollView} = require 'atom-space-pen-views'

defaultMessage = 'Nothing new to show'

class OutputView extends ScrollView
  @content: ->
    @div class: 'git-plus info-view', =>
      @pre class: 'output', defaultMessage

  html: defaultMessage

  initialize: -> super

  reset: -> @html = defaultMessage

  setContent: (content) ->
    @html = ansiToHtml.toHtml content
    this

  finish: ->
    @find(".output").html(@html)
    @show()
    @timeout = setTimeout =>
      @hide()
    , atom.config.get('git-plus.messageTimeout') * 1000

  toggle: ->
    clearTimeout @timeout if @timeout
    $.fn.toggle.call(this)

module.exports = OutputView
