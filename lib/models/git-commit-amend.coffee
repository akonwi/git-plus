Path = require 'path'
{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
git = require '../git'
notifier = require '../notifier'

disposables = new CompositeDisposable

prettifyStagedFiles = (data) ->
  return [] if data is ''
  data = data.split(/\0/)[...-1]
  [] = for mode, i in data by 2
    {mode, path: data[i+1] }

prettyifyPreviousFile = (data) ->
  mode: data[0]
  path: data.substring(1).trim()

prettifyFileStatuses = (files) ->
  files.map ({mode, path}) ->
    switch mode
      when 'M'
        "modified:   #{path}"
      when 'A'
        "new file:   #{path}"
      when 'D'
        "deleted:   #{path}"
      when 'R'
        "renamed:   #{path}"

getStagedFiles = (repo) ->
  git.stagedFiles(repo).then (files) ->
    if files.length >= 1
      args = ['diff-index', '--no-color', '--cached', 'HEAD', '--name-status', '-z']
      git.cmd(args, cwd: repo.getWorkingDirectory())
      .then (data) -> prettifyStagedFiles data
    else
      Promise.resolve []

getGitStatus = (repo) ->
  git.cmd ['-c', 'color.ui=false', 'status'], cwd: repo.getWorkingDirectory()

diffFiles = (previousFiles, currentFiles) ->
  previousFiles = previousFiles.map (p) -> prettyifyPreviousFile p
  currentPaths = currentFiles.map ({path}) -> path
  previousFiles.filter (p) -> p.path in currentPaths is false

parse = (prevCommit) ->
  lines = prevCommit.split(/\n/).filter (line) -> line isnt '/n'
  statusRegex = /(([ MADRCU?!])\s(.*))/
  indexOfStatus = lines.findIndex (line) -> statusRegex.test line

  prevMessage = lines.splice 0, indexOfStatus - 1
  prevMessage.reverse()
  prevMessage.shift() if prevMessage[0] is ''
  prevMessage.reverse()
  prevChangedFiles = lines.filter (line) -> line isnt ''
  message = prevMessage.join('\n')
  {message, prevChangedFiles}

cleanupUnstagedText = (status) ->
  unstagedFiles = status.indexOf "Changes not staged for commit:"
  if unstagedFiles >= 0
    text = status.substring unstagedFiles
    status = "#{status.substring(0, unstagedFiles - 1)}\n#{text.replace /\s*\(.*\)\n/g, ""}"
  else
    status

prepFile = ({commentChar, message, prevChangedFiles, status, filePath}) ->
    status = cleanupUnstagedText status
    status = status.replace(/\s*\(.*\)\n/g, "\n").replace(/\n/g, "\n#{commentChar} ")
    if prevChangedFiles.length > 0
      nothingToCommit = "nothing to commit, working directory clean"
      currentChanges = "committed:\n#{commentChar}"
      textToReplace = null
      if status.indexOf(nothingToCommit) > -1
        textToReplace = nothingToCommit
      else if status.indexOf(currentChanges) > -1
        textToReplace = currentChanges
      replacementText =
        """committed:
        #{
          prevChangedFiles.map((f) -> "#{commentChar}   #{f}").join("\n")
        }"""
      status = status.replace textToReplace, replacementText
    fs.writeFileSync filePath,
      """#{message}
      #{commentChar} Please enter the commit message for your changes. Lines starting
      #{commentChar} with '#{commentChar}' will be ignored, and an empty message aborts the commit.
      #{commentChar}
      #{commentChar} #{status}"""

showFile = (filePath) ->
  commitEditor = atom.workspace.paneForURI(filePath)?.itemForURI(filePath)
  if not commitEditor
    if atom.config.get('git-plus.general.openInPane')
      splitDirection = atom.config.get('git-plus.general.splitPane')
      atom.workspace.getCenter().getActivePane()["split#{splitDirection}"]()
    atom.workspace.open filePath
  else
    if atom.config.get('git-plus.general.openInPane')
      atom.workspace.paneForURI(filePath).activate()
    else
      atom.workspace.paneForURI(filePath).activateItemForURI(filePath)
    Promise.resolve(commitEditor)

destroyCommitEditor = (filePath) ->
  if atom.config.get('git-plus.general.openInPane')
    atom.workspace.paneForURI(filePath)?.destroy()
  else
    atom.workspace.paneForURI(filePath).itemForURI(filePath)?.destroy()

commit = (directory, filePath) ->
  args = ['commit', '--amend', '--cleanup=strip', "--file=#{filePath}"]
  git.cmd(args, cwd: directory)
  .then (data) ->
    notifier.addSuccess data
    destroyCommitEditor(filePath)
    git.refresh()
  .catch (data) ->
    notifier.addError data
    destroyCommitEditor(filePath)

cleanup = (currentPane, filePath) ->
  currentPane.activate() if currentPane.isAlive()
  disposables.dispose()

module.exports = (repo) ->
  currentPane = atom.workspace.getActivePane()
  filePath = Path.join(repo.getPath(), 'COMMIT_EDITMSG')
  cwd = repo.getWorkingDirectory()
  commentChar = git.getConfig(repo, 'core.commentchar') ? '#'
  git.cmd(['whatchanged', '-1', '--name-status', '--format=%B'], {cwd})
  .then (amend) -> parse amend
  .then ({message, prevChangedFiles}) ->
    getStagedFiles(repo)
    .then (files) ->
      prevChangedFiles = prettifyFileStatuses(diffFiles prevChangedFiles, files)
      {message, prevChangedFiles}
  .then ({message, prevChangedFiles}) ->
    getGitStatus(repo)
    .then (status) -> prepFile {commentChar, message, prevChangedFiles, status, filePath}
    .then -> showFile filePath
  .then (textEditor) ->
    disposables.add textEditor.onDidSave -> commit(repo.getWorkingDirectory(), filePath)
    disposables.add textEditor.onDidDestroy -> cleanup currentPane, filePath
  .catch (msg) -> notifier.addInfo msg
