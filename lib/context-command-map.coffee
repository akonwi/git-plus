git = require './git'
GitDiffTool = require './models/git-difftool'
GitCommit = require './models/git-commit'

map =
  'difftool': ({repo, file}) -> GitDiffTool repo, {file}
  'add': ({repo, file}) -> git.add repo, {file}
  'add-and-commit': ({repo, file}) -> git.add(repo, {file}).then -> GitCommit(repo)

module.exports = (key, args) -> map[key](args)
