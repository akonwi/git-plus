{ScrollView} = require 'atom'

module.exports =
  class OutputView extends ScrollView
    @content: ->
      @div class: 'git-plus info-view', =>
        @pre class: 'output'

    initialize: ->
      super
      atom.workspaceView.appendToBottom(this)
      atom.workspaceView.command "git-plus:hide-output", => @detach()

    addLine: (line) ->
      @find(".output").append(line)

    finish: ->
      setTimeout =>
        @detach()
      , 10000
