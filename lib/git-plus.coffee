GitPlusView = require './git-plus-view'

module.exports =
  gitPlusView: null

  activate: (state) ->
    @gitPlusView = new GitPlusView(state.gitPlusViewState)

  deactivate: ->
    @gitPlusView.destroy()

  serialize: ->
    gitPlusViewState: @gitPlusView.serialize()
