git = require '../git'
MergeListView = require '../views/merge-list-view'

module.exports = (repo, {remote, noFastForward}={}) ->
  extraArgs = if noFastForward then ['--no-ff'] else []
  args = ['branch']
  args.push '-r' if remote
  git.cmd(args, cwd: repo.getWorkingDirectory())
  .then (data) -> new MergeListView(repo, data, extraArgs)
