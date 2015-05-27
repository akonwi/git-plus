git = require '../git'
GitCommit = require './git-commit'

gitCommitAmend = (repo) ->
  git.cmd
    args: ['log', '-1', '--format=%B']
    cwd: repo.getWorkingDirectory()
    stdout: (amend) ->
      git.cmd
        args: ['reset', '--soft', 'HEAD^']
        cwd: repo.getWorkingDirectory()
        exit: -> new GitCommit(repo, amend: "#{amend?.trim()}\n")

module.exports = gitCommitAmend
