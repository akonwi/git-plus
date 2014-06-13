{ScrollView} = require 'atom'

module.exports =
  class OutputView extends ScrollView
    
    message: ''
    
    @content: ->
      @div class: 'git-plus info-view', =>
        @pre class: 'output'

    initialize: ->
      super
      atom.workspaceView.appendToBottom(this)

    addLine: (line) ->
      @message += line

    reset: ->
      @message = ''
    
    finish: ->
      @find(".output").append(@message)
      setTimeout =>
        @detach()
      , 10000
