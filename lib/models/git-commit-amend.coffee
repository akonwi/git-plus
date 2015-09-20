fs = require 'fs-plus'
Path = require 'flavored-path'
git = require '../git'
GitCommit = require './git-commit-beta'
notifier = require '../notifier'

prettifyStagedFiles = (data) ->
  return [] if data is ''
  data = data.split(/\0/)[...-1]
  [] = for mode, i in data by 2
    {mode, path: data[i+1] }

prettyifyPreviousFile = (data) ->
  mode: data[0]
  path: data.substring(1)

getStagedFiles = (repo) ->
  git.stagedFiles(repo).then (files) ->
    if files.length >= 1
      args = ['diff-index', '--cached', 'HEAD', '--name-status', '-z']
      git.cmd(args, cwd: repo.getWorkingDirectory())
      .then (data) -> prettifyStagedFiles data
    else
      Promise.reject "Nothing to commit."

getTemplate = ->
  git.cmd(['config', '--get', 'commit.template']).then (filePath) ->
    if filePath
      fs.readFileSync(Path.get(filePath.trim())).toString().trim()
    else filePath

mergeFiles = (previousFiles, currentFiles) ->
  previousFiles = previousFiles.map (p) -> prettyifyPreviousFile p
  currentPaths = currentFiles.map ({path}) -> path
  previous = previousFiles.filter (p) -> p.path in currentPaths is false
  previous.concat currentFiles

parse = (prevCommit) ->
  lines = prevCommit.split(/\n/).filter (line) -> line isnt ''
  message = []
  prevChangedFiles = []
  lines.forEach (line) ->
    unless /(([ MADRCU?!])\s(.*))/.test line
      message.push line
    else
      prevChangedFiles.push line.replace(/[ MADRCU?!](\s)(\s)*/, line[0])
  [message.join('\n'), prevChangedFiles]

prepFile = (prevCommit, files, filePath) ->
  git.cmd(['config', '--get', 'core.commentchar']).then (commentchar) ->
    commentchar = if commentchar.length > 0 then commentchar.trim() else '#'
    prevStatus = files.trim().replace(/\n/g, "\n#{commentchar} ")
    status = status.replace(/\n/g, "\n#{commentchar} ")
    getTemplate().then (template) ->
      fs.writeFileSync filePath,
        """#{message}
        #{commentchar} Please enter the commit message for your changes. Lines starting
        #{commentchar} with '#{commentchar}' will be ignored, and an empty message aborts the commit.
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
  .then (amend) -> parse amend
  .then ([message, prevChangedFiles]) ->
    getStagedFiles(repo).then (files) -> mergeFiles prevChangedFiles, files
  .catch (msg) -> notifier.addInfo msg
  # .then (amend) ->getStagedFiles(repo)
  # .then (files) ->
  #   prepFile amend, files, filePath
  # .then (data) ->
  #   GitCommit repo, amend: true
  # .catch (msg) ->
  #   notifier.addError "There was an issue retrieving the last commit"
