git = require '../git'

filesFromData = (statusData) ->
  files = []
  for line in statusData
    lineMatch = line.match /^([ MARCU?!]{2})\s{1}(.*)/
    files.push lineMatch[2] if lineMatch
  files

module.exports = (repo) ->
  git.status(repo).then (statusData) ->
    for file in filesFromData(statusData)
      atom.workspace.open(file)
