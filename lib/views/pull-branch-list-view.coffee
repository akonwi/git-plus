{BufferedProcess} = require 'atom'
OutputViewManager = require '../output-view-manager'
notifier = require '../notifier'
BranchListView = require './branch-list-view'

module.exports =
  # Extension of BranchListView
  # Takes the name of the remote to pull from
  class PullBranchListView extends BranchListView
    initialize: (@repo, @data, @remote, @extraArgs, @resolve) -> super

    parseData: ->
      @currentBranchString = '== Current =='
      currentBranch =
        name: @currentBranchString
      items = @data.split("\n")
      branches = items.filter((item) -> item isnt '').map (item) ->
        name: item.replace(/\s/g, '')
      if branches.length is 1
        @confirmed branches[0]
      else
        @setItems [currentBranch].concat branches
      @focusFilterEditor()

    confirmed: ({name}) ->
      if name is @currentBranchString
        @pull()
      else
        @pull name.substring(name.indexOf('/') + 1)
      @cancel()

    pull: (remoteBranch='') ->
      view = OutputViewManager.new()
      startMessage = notifier.addInfo "Pulling...", dismissable: true
      new BufferedProcess
        command: atom.config.get('git-plus.gitPath') ? 'git'
        args: ['pull'].concat(@extraArgs, @remote, remoteBranch).filter((arg) -> arg isnt '')
        options:
          cwd: @repo.getWorkingDirectory()
        stdout: (data) -> view.addLine(data.toString())
        stderr: (data) -> view.addLine(data.toString())
        exit: (code) =>
          @resolve()
          view.finish()
          startMessage.dismiss()
