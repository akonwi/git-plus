git = require '../git'
notifier = require '../notifier'
BranchListView = require './branch-list-view'

module.exports =
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
      notification = notifier.addInfo "Deleting remote branch #{branch}", dismissable: true
      args = if remote then ['push', remote, '--delete'] else ['branch', '-D']
      git.cmd(args.concat(branch), cwd: @repo.getWorkingDirectory())
      .then (message) ->
        notification.dismiss()
        notifier.addSuccess message
      .catch (error) ->
        notification.dismiss()
        notifier.addError error
