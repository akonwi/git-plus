GitDiffTool = require './models/git-difftool'

map =
  'difftool': ({repo, file}) -> GitDiffTool repo, {file}

module.exports = (key, args) -> map[key](args)
