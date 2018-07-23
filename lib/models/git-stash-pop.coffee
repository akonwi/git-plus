git = require('../git-es').default
ActivityLogger = require('../activity-logger').default

module.exports = (repo) ->
  cwd = repo.getWorkingDirectory()
  git(['stash', 'pop'], {cwd, color: true})
  .then (result) ->
    ActivityLogger.record(Object.assign({message: 'Pop stash'}, result))
