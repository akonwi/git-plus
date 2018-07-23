git = require('../git-es').default
ActivityLogger = require('../activity-logger').default

module.exports = (repo) ->
  cwd = repo.getWorkingDirectory()
  git(['stash', 'apply'], {cwd, color: true})
  .then (result) ->
    ActivityLogger.record(Object.assign({message: 'Apply stash'}, result))
