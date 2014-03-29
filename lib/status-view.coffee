{View} = require 'atom'

module.exports =
class StatusView extends View
  @content = =>
    @div class: 'git-plus overlay from-top', =>
      @div class: 'message'

  initialize: -> @toggle()

  # Returns an object that can be retrieved when package is activated
  # comment
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    "GitPlusView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
