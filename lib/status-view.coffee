{View} = require 'atom'

module.exports =
  class StatusView extends View
    @content = (params) ->
      @div class: 'git-plus overlay from-bottom', =>
        @div class: "#{params.type} message", params.message

    initialize: ->
      atom.workspaceView.append(this)
      setTimeout =>
        @detach()
      , 5000
