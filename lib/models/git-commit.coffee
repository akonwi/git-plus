Path = require 'path'
{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
git = require '../git'
notifier = require '../notifier'
GitPush = require './git-push'
GitPull = require './git-pull'

disposables = new CompositeDisposable

verboseCommitsEnabled = -> atom.config.get('git-plus.commits.verboseCommits')

getStagedFiles = (repo) ->
  git.stagedFiles(repo).then (files) ->
    if files.length >= 1
      git.cmd(['-c', 'color.ui=false', 'status'], cwd: repo.getWorkingDirectory())
    else
      Promise.reject "Nothing to commit."

getTemplate = (filePath) ->
  if filePath
    try
      fs.readFileSync(fs.absolute(filePath.trim())).toString().trim()
    catch e
      throw new Error("Your configured commit template file can't be found.")
  else
    ''

prepFile = ({status, filePath, diff, commentChar, template}) ->
  if commitEditor = atom.workspace.paneForURI(filePath)?.itemForURI(filePath)
    text = commitEditor.getText()
    indexOfComments = text.indexOf(commentChar)
    if indexOfComments > 0
      template = text.substring(0, indexOfComments - 1)

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

destroyCommitEditor = (filePath) ->
  if atom.config.get('git-plus.general.openInPane')
    atom.workspace.paneForURI(filePath)?.destroy()
  else
    atom.workspace.paneForURI(filePath).itemForURI(filePath)?.destroy()

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
    destroyCommitEditor(filePath)
    git.refresh()
  .catch (data) ->
    notifier.addError data
    destroyCommitEditor(filePath)

cleanup = (currentPane) ->
  currentPane.activate() if currentPane.isAlive()
  disposables.dispose()

showFile = (filePath) ->
  commitEditor = atom.workspace.paneForURI(filePath)?.itemForURI(filePath)
  if not commitEditor
    if atom.config.get('git-plus.general.openInPane')
      splitDirection = atom.config.get('git-plus.general.splitPane')
      atom.workspace.getActivePane()["split#{splitDirection}"]()
    atom.workspace.open filePath
  else
    if atom.config.get('git-plus.general.openInPane')
      atom.workspace.paneForURI(filePath).activate()
    else
      atom.workspace.paneForURI(filePath).activateItemForURI(filePath)
    Promise.resolve(commitEditor)

module.exports = (repo, {stageChanges, andPush}={}) ->
  filePath = Path.join(repo.getPath(), 'COMMIT_EDITMSG')
  currentPane = atom.workspace.getActivePane()
  commentChar = git.getConfig(repo, 'core.commentchar') ? '#'
  try
    template = getTemplate(git.getConfig(repo, 'commit.template'))
  catch e
    notifier.addError(e.message)
    return Promise.reject(e.message)

  init = -> getStagedFiles(repo).then (status) ->
    if verboseCommitsEnabled()
      args = ['diff', '--color=never', '--staged']
      args.push '--word-diff' if atom.config.get('git-plus.diffs.wordDiff')
      git.cmd(args, cwd: repo.getWorkingDirectory())
      .then (diff) -> prepFile {status, filePath, diff, commentChar, template}
    else
      prepFile {status, filePath, commentChar, template}
  startCommit = ->
    showFile filePath
    .then (textEditor) ->
      disposables.dispose()
      disposables = new CompositeDisposable
      disposables.add textEditor.onDidSave ->
        trimFile(filePath, commentChar) if verboseCommitsEnabled()
        commit(repo.getWorkingDirectory(), filePath)
        .then -> GitPush(repo) if andPush
      disposables.add textEditor.onDidDestroy -> cleanup(currentPane)
    .catch(notifier.addError)

  if stageChanges
    git.add(repo, update: true).then(init).then(startCommit)
  else
    init().then -> startCommit()
    .catch (message) ->
      if message.includes?('CRLF')
        startCommit()
      else
        notifier.addInfo message
