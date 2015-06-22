git = require '../git'
OutputView = require './output-view'
BranchListView = require './branch-list-view'

module.exports =
  # Extension of BranchListView
  # Takes the name of the remote to pull from
  class PullBranchListView extends BranchListView
    initialize: (@repo, @data, @remote, @extraArgs) ->
      super

    confirmed: ({name}) ->
      @pull name.substring(name.indexOf('/') + 1)
      @cancel()

    pull: (remoteBranch='') ->
      view = new OutputView()
      git.cmd
        args: ['pull'].concat(@extraArgs, @remote, remoteBranch)
        cwd: @repo.getWorkingDirectory()
        stdout: (data) -> view.addLine(data.toString())
        stderr: (data) -> view.addLine(data.toString())
        exit: (code) => view.finish()
