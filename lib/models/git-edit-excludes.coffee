{join} = require 'path'

module.exports = (repo) ->
  excludes = join(repo.getPath(), 'info', 'exclude')
  atom.workspace.open excludes
