fs = require 'fs-plus'
Path = require 'flavored-path'
git = require '../git'
GitCommit = require './git-commit'

getStagedFiles = (repo) ->
  git.stagedFiles(repo).then (files) ->
    if files.length >= 1
      git.cmd(['status'], cwd: repo.getWorkingDirectory())
    else
      Promise.reject "Nothing to commit."

getTemplate = ->
  git.cmd(['config', '--get', 'commit.template']).then (filePath) ->
    if filePath
      fs.readFileSync(Path.get(filePath.trim())).toString().trim()
    else filePath

prepFile = (prevCommit, status, filePath) ->
  lines = prevCommit.split /\n/
  lines = lines.filter (line) -> line isnt ''
  message = []
  files = []
  lines.forEach (line) ->
    unless /(([ MADRCU?!])\s(.*))/.test line
      message.push line
    else
      switch line[0]
        when 'M'
          line = "modified:#{line.substring(1)}"
        when 'A'
          line = "added:#{line.substring(1)}"
        when 'D'
          line = "deleted:#{line.substring(1)}"
        when 'R'
          line = "renamed:#{line.substring(1)}"
        when 'C'
          line = "copied:#{line.substring(1)}"
        when 'U'
          line = "updated:#{line.substring(1)}"
      files.push line
  message = message.join('\n')
  files = files.join('\n')
  git.cmd(['config', '--get', 'core.commentchar']).then (commentchar) ->
    commentchar = if commentchar.length > 0 then commentchar.trim() else '#'
    prevStatus = files.trim().replace(/\n/g, "\n#{commentchar} ")
    getTemplate().then (template) ->
      fs.writeFileSync filePath,
        """#{message}
        #{commentchar} This is the status of the previous commit
        #{commentchar}
        #{commentchar} #{prevStatus}
        #{commentchar}
        #{commentchar} This is the current status to be committed
        #{commentchar}
        #{commentchar} #{status}"""

module.exports = (repo) ->
  filePath = Path.join(repo.getPath(), 'COMMIT_EDITMSG')
  cwd = repo.getWorkingDirectory()
  git.cmd(['whatchanged', '-1', '--name-status', '--format=%B'], {cwd})
  .then (amend) ->
    getStagedFiles(repo).then (status) ->
      prepFile amend, status, filePath
