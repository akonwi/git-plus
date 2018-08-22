git = require('../git-es').default
ActivityLogger = require('../activity-logger').default
Repository = require('../repository').default

module.exports = (repo) ->
  cwd = repo.getWorkingDirectory()
  git(['stash', 'apply'], {cwd, color: true})
  .then (result) ->
    repoName = new Repository(repo).getName()
    ActivityLogger.record(Object.assign({repoName, message: 'Apply stash'}, result))
