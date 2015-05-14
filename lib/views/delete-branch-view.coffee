git = require '../git'
OutputView = require './output-view'
BranchListView = require './branch-list-view'

module.exports =
  # Extension of BranchListView
  class DeleteBranchListView extends BranchListView
    initialize: (@repo, @data, @remote) -> super

    confirmed: ({name}) ->
      if name.startsWith "*"
        name = name.slice(1)

      if !@remote
        console.log name
        @delete name
      else
        branch = name.substring(name.indexOf('/') + 1)
        remote = name.substring(0, name.indexOf('/'))

        @delete branch, remote, true
      @cancel()

    delete: (branch = '', remote = '', isRemote = false) ->
      view = new OutputView()

      if not isRemote
        git.cmd
          args: ['branch', '-D', branch]
          cwd: @repo.getWorkingDirectory()
          stdout: (data) -> view.addLine(data.toString())
          stderr: (data) -> view.addLine(data.toString())
          exit: (code) => view.finish()
      else
        git.cmd
          args: ['push', remote, '--delete', branch]
          cwd: @repo.getWorkingDirectory()
          stdout: (data) -> view.addLine(data.toString())
          stderr: (data) -> view.addLine(data.toString())
          exit: (code) => view.finish()
