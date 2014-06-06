GitCommit = require './git-commit'
GitAdd = require './git-add'

#Add and commit current file only
gitAddAndCommit = ->
  GitAdd()
  GitCommit()

module.exports = gitAddAndCommit
