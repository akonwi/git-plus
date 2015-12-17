git = require '../git'
notifier = require '../notifier'
BranchListView = require './branch-list-view'

module.exports =
  # Extension of BranchListView
  class DeleteBranchListView extends BranchListView
    initialize: (@repo, @data, {@isRemote}={}) -> super

    confirmed: ({name}) ->
      name = name.slice(1) if name.startsWith "*"
      unless @isRemote
        @delete name
      else
        branch = name.substring(name.indexOf('/') + 1)
        remote = name.substring(0, name.indexOf('/'))
        @delete branch, remote
      @cancel()

    delete: (branch, remote) ->
      args = if remote then ['push', remote, '--delete'] else ['branch', '-D']
      git.cmd(args.concat(branch), cwd: @repo.getWorkingDirectory())
      .then (message) -> notifier.addSuccess message
      .catch (error) -> notifier.addError error
