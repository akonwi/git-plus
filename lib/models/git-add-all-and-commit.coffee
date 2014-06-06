GitCommit = require './git-commit'
GitAdd = require './git-add'

#Add and commit current file only
gitAddAllAndCommit = ->
  GitAdd(true)
  GitCommit()

module.exports = gitAddAllAndCommit
