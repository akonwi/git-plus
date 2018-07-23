git = require('../git-es').default
ActivityLogger = require('../activity-logger').default

module.exports = (repo) ->
  cwd = repo.getWorkingDirectory()
  git(['stash', 'drop'], {cwd, color: true})
  .then (result) ->
    ActivityLogger.record(Object.assign({message: 'Drop stash'}, result))
