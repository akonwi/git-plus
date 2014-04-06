{View} = require 'atom'

module.exports =
  class StatusView extends View
    @content = (params) ->
      @div class: 'git-plus overlay from-bottom', =>
        @div class: 'alert message', params.message

    initialize: ->
      atom.workspaceView.append(this)
      setTimeout =>
        @detach()
      , 10000
