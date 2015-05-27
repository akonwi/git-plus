git = require '../git'
notifier = require '../notifier'
BranchListView = require './branch-list-view'

module.exports =
  # Extension of BranchListView
  class DeleteBranchListView extends BranchListView
    initialize: (@repo, @data) -> super

    confirmed: ({name}) ->
      if name.startsWith "*"
        name = name.slice(1)

      if name.indexOf('/') is -1
        @delete name
      else
        branch = name.substring(name.indexOf('/') + 1)
        remote = name.substring(0, name.indexOf('/'))

        @delete branch, remote, true
      @cancel()

    delete: (branch = '', remote = '', isRemote = false) ->
      if not isRemote
        git.cmd
          args: ['branch', '-D', branch]
          cwd: @repo.getWorkingDirectory()
          stdout: (data) -> notifier.addSuccess(data.toString())
      else
        git.cmd
          args: ['push', remote, '--delete', branch]
          cwd: @repo.getWorkingDirectory()
          stderr: (data) -> notifier.addSuccess(data.toString())
