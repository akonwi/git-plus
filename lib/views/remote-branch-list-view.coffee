BranchListView = require './branch-list-view'

isValidBranch = (item, remote) ->
  item.startsWith(remote + '/') and not item.includes('/HEAD')

module.exports =
  class RemoteBranchListView extends BranchListView
    initialize: (data, @remote, onConfirm) ->
      super(data, onConfirm)

    parseData: ->
      items = @data.split("\n").map (item) -> item.replace(/\s/g, '')
      branches = items.filter((item) => isValidBranch(item, @remote)).map (item) -> {name: item}
      if branches.length is 1
        @confirmed branches[0]
      else
        @setItems branches
      @focusFilterEditor()
