Path = require 'path'
{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
git = require '../git'
notifier = require '../notifier'
GitPush = require './git-push'
GitPull = require './git-pull'

disposables = new CompositeDisposable

verboseCommitsEnabled = -> atom.config.get('git-plus.experimental') and atom.config.get('git-plus.verboseCommits')

getStagedFiles = (repo) ->
  git.stagedFiles(repo).then (files) ->
    if files.length >= 1
      git.cmd(['status'], cwd: repo.getWorkingDirectory())
    else
      Promise.reject "Nothing to commit."

getTemplate = (filePath) ->
  if filePath
    fs.readFileSync(fs.absolute(filePath.trim())).toString().trim()
  else
    ''

prepFile = ({status, filePath, diff, commentChar, template}) ->
  cwd = Path.dirname(filePath)
  status = status.replace(/\s*\(.*\)\n/g, "\n")
  status = status.trim().replace(/\n/g, "\n#{commentChar} ")
  content =
    """#{template}
    #{commentChar} Please enter the commit message for your changes. Lines starting
    #{commentChar} with '#{commentChar}' will be ignored, and an empty message aborts the commit.
    #{commentChar}
    #{commentChar} #{status}"""
  if diff
    content +=
      """\n#{commentChar}
      #{commentChar} ------------------------ >8 ------------------------
      #{commentChar} Do not touch the line above.
      #{commentChar} Everything below will be removed.
      #{diff}"""
  fs.writeFileSync filePath, content

destroyCommitEditor = ->
  atom.workspace?.getPanes().some (pane) ->
    pane.getItems().some (paneItem) ->
      if paneItem?.getURI?()?.includes 'COMMIT_EDITMSG'
        if pane.getItems().length is 1
          pane.destroy()
        else
          paneItem.destroy()
        return true

trimFile = (filePath, commentChar) ->
  cwd = Path.dirname(filePath)
  content = fs.readFileSync(fs.absolute(filePath)).toString()
  startOfComments = content.indexOf(content.split('\n').find (line) -> line.startsWith commentChar)
  content = content.substring(0, startOfComments)
  fs.writeFileSync filePath, content

commit = (directory, filePath) ->
  git.cmd(['commit', "--cleanup=strip", "--file=#{filePath}"], cwd: directory)
  .then (data) ->
    notifier.addSuccess data
    destroyCommitEditor()
    git.refresh()
  .catch (data) ->
    notifier.addError data
    destroyCommitEditor()

cleanup = (currentPane, filePath) ->
  currentPane.activate() if currentPane.isAlive()
  disposables.dispose()
  fs.unlink filePath

showFile = (filePath) ->
  if atom.config.get('git-plus.openInPane')
    splitDirection = atom.config.get('git-plus.splitPane')
    atom.workspace.getActivePane()["split#{splitDirection}"]()
  atom.workspace.open filePath

module.exports = (repo, {stageChanges, andPush}={}) ->
  filePath = Path.join(repo.getPath(), 'COMMIT_EDITMSG')
  currentPane = atom.workspace.getActivePane()
  commentChar = git.getConfig(repo, 'core.commentchar') ? '#'
  template = getTemplate(git.getConfig(repo, 'commit.template'))
  init = -> getStagedFiles(repo).then (status) ->
    if verboseCommitsEnabled()
      args = ['diff', '--color=never', '--staged']
      args.push '--word-diff' if atom.config.get('git-plus.wordDiff')
      git.cmd(args, cwd: repo.getWorkingDirectory())
      .then (diff) -> prepFile {status, filePath, diff, commentChar, template}
    else
      prepFile {status, filePath, commentChar, template}
  startCommit = ->
    showFile filePath
    .then (textEditor) ->
      disposables.add textEditor.onDidSave ->
        trimFile(filePath, commentChar) if verboseCommitsEnabled()
        commit(repo.getWorkingDirectory(), filePath)
        .then -> GitPush(repo) if andPush
      disposables.add textEditor.onDidDestroy -> cleanup currentPane, filePath
    .catch (msg) -> notifier.addError msg

  if stageChanges
    git.add(repo, update: stageChanges).then(-> init()).then -> startCommit()
  else
    init().then -> startCommit()
    .catch (message) ->
      if message.includes?('CRLF')
        startCommit()
      else
        notifier.addInfo message
