git = require '../git'
BranchListView = require '../views/branch-list-view'

module.exports =
class RemoteBranchListView extends BranchListView
  args: ['checkout', '-t']
