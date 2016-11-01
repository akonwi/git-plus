git = require './git'
GitDiffTool = require './models/git-difftool'

map =
  'difftool': ({repo, file}) -> GitDiffTool repo, {file}
  'add': ({repo, file}) -> git.add repo, {file}

module.exports = (key, args) -> map[key](args)
