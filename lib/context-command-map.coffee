git = require './git'
GitCommit = require './models/git-commit'
GitDiff = require './models/git-diff'
GitDiffTool = require './models/git-difftool'

map =
  'difftool': ({repo, file}) -> GitDiffTool repo, {file}
  'add': ({repo, file}) -> git.add repo, {file}
  'diff': ({repo, file}) -> GitDiff(repo, {file})
  'add-and-commit': ({repo, file}) -> git.add(repo, {file}).then -> GitCommit(repo)

module.exports = (key, args) -> map[key](args)
