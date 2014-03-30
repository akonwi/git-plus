GitCommit = require './git-commit'

module.exports =
  # TODO: Move commit stuff into separate module
  #   each command should get its own file/module
  activate: (state) ->
    atom.workspaceView.command "git-plus:commit", -> GitCommit()

  deactivate: ->
    # @gitPlusView.destroy()

  serialize: ->
    # gitPlusViewState: @gitPlusView.serialize()
