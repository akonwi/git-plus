git = require('../git-es').default
ActivityLogger = require('../activity-logger').default
Repository = require('../repository').default

module.exports = (repo, {message}={}) ->
  cwd = repo.getWorkingDirectory()
  args = ['stash', 'save']
  args.push(message) if message
  git(args, {cwd, color: true})
  .then (result) ->
    repoName = new Repository(repo).getName()
    ActivityLogger.record(Object.assign({repoName, message: 'Stash changes'} ,result))
