git = require '../git'
OutputViewManager = require '../output-view-manager'
notifier = require '../notifier'
BranchListView = require './branch-list-view'

isValidBranch = (item, remote) ->
  item.startsWith(remote + '/') and not item.includes('/HEAD')

module.exports =
  # Extension of BranchListView
  # Takes the name of the remote to push to
  class PushBranchListView extends BranchListView
    initialize: (@repo, @data, @remote, @extraArgs) ->
      super
      @result = new Promise (resolve, reject) =>
        @resolve = resolve
        @reject = reject

    parseData: ->
      items = @data.split("\n").map (item) -> item.replace(/\s/g, '')
      branches = items.filter((item) => isValidBranch(item, @remote)).map (item) -> {name: item}
      if branches.length is 1
        @confirmed branches[0]
      else
        @setItems branches
      @focusFilterEditor()

    confirmed: ({name}) ->
      @push name.substring(name.indexOf('/') + 1)
      @cancel()

    push: (remoteBranch) ->
      view = OutputViewManager.create()
      startMessage = notifier.addInfo "Pushing...", dismissable: true
      args = ['push'].concat(@extraArgs, @remote, remoteBranch).filter((arg) -> arg isnt '')
      git.cmd(args, cwd: @repo.getWorkingDirectory(), {color: true})
      .then (data) =>
        @resolve()
        view.setContent(data).finish()
        startMessage.dismiss()
        git.refresh @repo
      .catch (error) =>
        ## Should @result be rejected for those depending on this view?
        # @reject()
        view.setContent(error).finish()
        startMessage.dismiss()
