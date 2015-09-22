{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
Path = require 'flavored-path'
git = require '../git'
GitCommit = require './git-commit-beta'
notifier = require '../notifier'

disposables = new CompositeDisposable

prettifyStagedFiles = (data) ->
  return [] if data is ''
  data = data.split(/\0/)[...-1]
  [] = for mode, i in data by 2
    {mode, path: data[i+1] }

prettyifyPreviousFile = (data) ->
  mode: data[0]
  path: data.substring(1)

prettifyFileStatuses = (files) ->
  files.map ({mode, path}) ->
    switch mode
      when 'M'
        "modified:   #{path}"
      when 'A'
        "new file:   #{path}"
      when 'D'
        "removed:   #{path}"
      when 'R'
        "renamed:   #{path}"

getStagedFiles = (repo) ->
  git.stagedFiles(repo).then (files) ->
    if files.length >= 1
      args = ['diff-index', '--cached', 'HEAD', '--name-status', '-z']
      git.cmd(args, cwd: repo.getWorkingDirectory())
      .then (data) -> prettifyStagedFiles data
    else
      Promise.reject "Nothing to commit."

getGitStatus = (repo) ->
  git.cmd ['status'], cwd: repo.getWorkingDirectory()

getTemplate = ->
  git.cmd(['config', '--get', 'commit.template']).then (filePath) ->
    if filePath
      fs.readFileSync(Path.get(filePath.trim())).toString().trim()
    else filePath

diffFiles = (previousFiles, currentFiles) ->
  previousFiles = previousFiles.map (p) -> prettyifyPreviousFile p
  currentPaths = currentFiles.map ({path}) -> path
  previousFiles.filter (p) -> p.path in currentPaths is false

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

cleanupUnstagedText = (status) ->
  unstagedFiles = status.indexOf "Changes not staged for commit:"
  if unstagedFiles >= 0
    text = status.substring unstagedFiles
    status = "#{status.substring(0, unstagedFiles - 1)}\n#{text.replace /\s*\(.*\)\n/g, ""}"
  else
    status

prepFile = (message, prevChangedFiles, status, filePath) ->
  git.cmd(['config', '--get', 'core.commentchar']).then (commentchar) ->
    commentchar = if commentchar.length > 0 then commentchar.trim() else '#'
    status = cleanupUnstagedText status
    status = status.replace(/\s*\(.*\)\n/g, "\n")
    .replace(/\n/g, "\n#{commentchar} ")
    .replace "committed:\n#{commentchar}", """committed:
    #{
      prevChangedFiles.map((f) -> "#{commentchar}   #{f}").join("\n")
    }"""
    fs.writeFileSync filePath,
      """#{message}
      #{commentchar} Please enter the commit message for your changes. Lines starting
      #{commentchar} with '#{commentchar}' will be ignored, and an empty message aborts the commit.
      #{commentchar}
      #{commentchar} #{status}"""

splitPane = (splitDir, oldEditor) ->
  pane = atom.workspace.paneForURI(oldEditor.getURI())
  options = { copyActiveItem: true }
  directions =
    left: =>
      pane.splitLeft options
    right: ->
      pane.splitRight options
    up: ->
      pane.splitUp options
    down: ->
      pane.splitDown options
  pane = directions[splitDir]().getActiveEditor()
  oldEditor.destroy()
  pane

showFile = (filePath) ->
  atom.workspace.open(filePath, searchAllPanes: true).then (textEditor) ->
    if atom.config.get('git-plus.openInPane')
      splitPane(atom.config.get('git-plus.splitPane'), textEditor)
    else
      textEditor

destroyCommitEditor = ->
  atom.workspace?.getPanes().some (pane) ->
    pane.getItems().some (paneItem) ->
      if paneItem?.getURI?()?.includes 'COMMIT_EDITMSG'
        if pane.getItems().length is 1
          pane.destroy()
        else
          paneItem.destroy()
        return true

dir = (repo) -> (git.getSubmodule() or repo).getWorkingDirectory()

commit = (directory, filePath) ->
  args = ['commit', '--amend', '--cleanup=strip', "--file=#{filePath}"]
  git.cmd(args, cwd: directory)
  .then (data) ->
    debugger
    notifier.addSuccess data
    destroyCommitEditor()
    git.refresh()

cleanup = (currentPane, filePath) ->
  currentPane.activate() if currentPane.alive
  disposables.dispose()
  try fs.unlinkSync filePath

module.exports = (repo) ->
  currentPane = atom.workspace.getActivePane()
  filePath = Path.join(repo.getPath(), 'COMMIT_EDITMSG')
  cwd = repo.getWorkingDirectory()
  git.cmd(['whatchanged', '-1', '--name-status', '--format=%B'], {cwd})
  .then (amend) -> parse amend
  .then ([message, prevChangedFiles]) ->
    getStagedFiles(repo).then (files) ->
      [message, prettifyFileStatuses(diffFiles prevChangedFiles, files)]
  .then ([message, prevChangedFiles]) ->
    getGitStatus(repo)
    .then (status) -> prepFile message, prevChangedFiles, status, filePath
    .then -> showFile filePath
  .then (textEditor) ->
    disposables.add textEditor.onDidSave -> commit(dir(repo), filePath)
    disposables.add textEditor.onDidDestroy -> cleanup currentPane, filePath
  .catch (msg) -> notifier.addInfo msg
