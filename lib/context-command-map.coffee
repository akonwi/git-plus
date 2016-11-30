git = require './git'
GitCheckoutFile = require './models/git-checkout-file'
GitCommit = require './models/git-commit'
GitDiff = require './models/git-diff'
GitDiffTool = require './models/git-difftool'

map =
  'add': ({repo, file}) -> git.add repo, {file}
  'add-and-commit': ({repo, file}) -> git.add(repo, {file}).then -> GitCommit(repo)
  'checkout-file': ({repo, file}) -> GitCheckoutFile repo, {file}
  'diff': ({repo, file}) -> GitDiff repo, {file}
  'difftool': ({repo, file}) -> GitDiffTool repo, {file}

module.exports = (key, args) -> map[key](args)
