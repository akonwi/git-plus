git = require '../git'
notifier = require '../notifier'

module.exports = (repo, {file}) ->
  git.cmd(['checkout', '--', file], cwd: repo.getWorkingDirectory())
  .then (data) ->
    notifier.addSuccess 'File changes checked out successfully'
    git.refresh repo
  .catch (error) ->
    notifier.addError error
