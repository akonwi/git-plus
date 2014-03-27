{View} = require 'atom'

module.exports =
class GitPlusView extends View
  @content: ->
    @div class: 'git-plus overlay from-top', =>
      @div "The GitPlus package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "git-plus:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "GitPlusView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
