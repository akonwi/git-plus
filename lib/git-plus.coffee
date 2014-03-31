GitCommit = require './git-commit'
GitWrite = require './git-write'

module.exports =
  # TODO: Move commit stuff into separate module
  #   each command should get its own file/module
  activate: (state) ->
    atom.workspaceView.command "git-plus:commit", -> GitCommit()
    atom.workspaceView.command "git-plus:write", -> GitWrite()

  deactivate: ->
    # @gitPlusView.destroy()

  serialize: ->
    # gitPlusViewState: @gitPlusView.serialize()
