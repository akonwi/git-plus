{join} = require 'path'

module.exports = (repo) ->
  config = join(repo.getPath(), 'config')
  atom.workspace.open config
