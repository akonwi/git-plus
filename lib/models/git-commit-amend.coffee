{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
Path = require 'flavored-path'
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
  path: data.substring(1)

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
      args = ['diff-index', '--cached', 'HEAD', '--name-status', '-z']
      git.cmd(args, cwd: repo.getWorkingDirectory())
      .then (data) -> prettifyStagedFiles data
    else
      Promise.resolve []

getGitStatus = (repo) ->
  git.cmd ['status'], cwd: repo.getWorkingDirectory()

diffFiles = (previousFiles, currentFiles) ->
  previousFiles = previousFiles.map (p) -> prettyifyPreviousFile p
  currentPaths = currentFiles.map ({path}) -> path
  previousFiles.filter (p) -> p.path in currentPaths is false

parse = (prevCommit) ->
  lines = prevCommit.split(/\n/).filter (line) -> line isnt ''
  prevMessage = []
  prevChangedFiles = []
  lines.forEach (line) ->
    unless /(([ MADRCU?!])\s(.*))/.test line
      prevMessage.push line
    else
      prevChangedFiles.push line.replace(/[ MADRCU?!](\s)(\s)*/, line[0])
  message = prevMessage.join('\n')
  {message, prevChangedFiles}

cleanupUnstagedText = (status) ->
  unstagedFiles = status.indexOf "Changes not staged for commit:"
  if unstagedFiles >= 0
    text = status.substring unstagedFiles
    status = "#{status.substring(0, unstagedFiles - 1)}\n#{text.replace /\s*\(.*\)\n/g, ""}"
  else
    status

prepFile = ({message, prevChangedFiles, status, filePath}) ->
  git.getConfig('core.commentchar', Path.dirname(filePath)).then (commentchar) ->
    commentchar = if commentchar.length > 0 then commentchar.trim() else '#'
    status = cleanupUnstagedText status
    status = status.replace(/\s*\(.*\)\n/g, "\n").replace(/\n/g, "\n#{commentchar} ")
    if prevChangedFiles.length > 0
      nothingToCommit = "nothing to commit, working directory clean"
      currentChanges = "committed:\n#{commentchar}"
      textToReplace = null
      if status.indexOf(nothingToCommit) > -1
        textToReplace = nothingToCommit
      else if status.indexOf(currentChanges) > -1
        textToReplace = currentChanges
      replacementText =
        """Changes to be committed:
        #{
          prevChangedFiles.map((f) -> "#{commentchar}   #{f}").join("\n")
        }"""
      status = status.replace textToReplace, replacementText
    fs.writeFileSync filePath,
      """#{message}
      #{commentchar} Please enter the commit message for your changes. Lines starting
      #{commentchar} with '#{commentchar}' will be ignored, and an empty message aborts the commit.
      #{commentchar}
      #{commentchar} #{status}"""

showFile = (filePath) ->
  if atom.config.get('git-plus.openInPane')
    splitDirection = atom.config.get('git-plus.splitPane')
    atom.workspace.getActivePane()["split#{splitDirection}"]()
  atom.workspace.open filePath

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
    notifier.addSuccess data
    destroyCommitEditor()
    git.refresh()

cleanup = (currentPane, filePath) ->
  currentPane.activate() if currentPane.isAlive()
  disposables.dispose()
  fs.unlink filePath

module.exports = (repo) ->
  currentPane = atom.workspace.getActivePane()
  filePath = Path.join(repo.getPath(), 'COMMIT_EDITMSG')
  cwd = repo.getWorkingDirectory()
  git.cmd(['whatchanged', '-1', '--name-status', '--format=%B'], {cwd})
  .then (amend) -> parse amend
  .then ({message, prevChangedFiles}) ->
    getStagedFiles(repo)
    .then (files) ->
      prevChangedFiles = prettifyFileStatuses(diffFiles prevChangedFiles, files)
      {message, prevChangedFiles}
  .then ({message, prevChangedFiles}) ->
    getGitStatus(repo)
    .then (status) -> prepFile {message, prevChangedFiles, status, filePath}
    .then -> showFile filePath
  .then (textEditor) ->
    disposables.add textEditor.onDidSave -> commit(dir(repo), filePath)
    disposables.add textEditor.onDidDestroy -> cleanup currentPane, filePath
  .catch (msg) -> notifier.addInfo msg
