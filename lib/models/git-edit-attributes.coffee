{join} = require 'path'

module.exports = (repo) ->
  attributes = join(repo.getPath(), 'info', 'attributes')
  atom.workspace.open attributes
