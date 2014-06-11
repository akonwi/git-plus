git = require '../git'

gitRefreshIndex = ->
  git(
    ['add', '--refresh', '.']
  )

module.exports = gitRefreshIndex
