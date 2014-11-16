git = require '../git'
OutputView = require './output-view'
BranchListView = require './branch-list-view'

module.exports =
  # Extension of BranchListView
  # Takes the name of the remote to pull from
  class PullBranchListView extends BranchListView
    initialize: (@remote) ->
      git.cmd
        args: ['branch', '-r'],
        stdout: (@data) =>
          super

    confirmed: ({name}) ->
      @pull(name.split('/')[1])
      @cancel()

    pull: (remoteBranch='') ->
      view = new OutputView()
      remote = @remote
      git.cmd
        args: ['fetch', @remote]
        stdout: (@data) ->
          if @data.toString().length is 0
            git.cmd
              args: ['merge', remote + "/" + remoteBranch]
              stdout: (data) -> view.addLine(data.toString())
              stderr: (data) -> view.addLine(data.toString())
              exit: (code) =>
                view.finish()
        stderr: (data) -> view.addLine(data.toString())

    # Once, 'pull' is fixed in Yosemite, revert back to this
    # pull: (remoteBranch='') ->
    #   view = new OutputView()
    #   git.cmd
    #     args: ['pull', @remote, remoteBranch]
    #     stdout: (data) -> view.addLine(data.toString())
    #     stderr: (data) -> view.addLine(data.toString())
    #     exit: (code) => view.finish()
