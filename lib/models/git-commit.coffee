fs = require 'fs-plus'
git = require '../git'
StatusView = require '../views/status-view'

currentPane = null
dir = ''
commitFilePath = -> dir + '/.git/COMMIT_EDITMSG'
commitEditor = null
watcher = null
amendMsg = ""

gitCommit = (_amendMsg="") ->
  currentPane = atom.workspace.getActivePane()
  dir = atom.project.getRepo().getWorkingDirectory()
  amendMsg = _amendMsg
  git(
    ['status'],
    (data) -> prepFile data.toString()
  )

# FIXME?: maybe I shouldn't use the COMMIT file in .git/
# TODO?: Strip out the git tips that 'git status' prints in message
prepFile = (text) ->
  watcher.close() if watcher?
  # format the text to be ignored in the commit message
  text = text.replace(/\n/g, "\n# ")
  # in order to make sure each line doesn't start with a space, the preceding
  #   line should end with a backslash
  fs.writeFileSync commitFilePath(),
     "#{amendMsg}\n\
      # Please enter the commit message for your changes. Lines starting\n\
      # with '#' will be ignored, and an empty message aborts the commit.\n\
      # Remove hyphen(-) and update commit message as necessary for amend.\n\
      # #{text}",
    flag: 'w+'
  showFile()

showFile = ->
  split = ''
  split = 'right'  if atom.config.get 'git-plus.openInPane'
  atom.workspace
    .open(commitFilePath(), split: split, activatePane: true)
    # ::open returns a promise resolving to the editor
    .done (editor) -> commitEditor = editor
  watcher = fs.watch commitFilePath(), (event) ->
    commit() if event is 'change'

commit = ->
  watcher.close()
  cleanFile()
  args = ['commit', "--file=#{commitFilePath()}"]
  args.push  '--amend' if amendMsg != ""
  git(
    args,
    (data) ->
      if atom.workspace.getActivePane().getItems().length > 1
        atom.workspace.destroyActivePaneItem()
      else
        atom.workspace.destroyActivePane()
      currentPane.activate()
      new StatusView(type: 'success', message: data.toString())
      # reset editor for commitFile
      currentEditor = null
      atom.workspaceView.trigger 'core:save'
  )

cleanFile = ->
  text = fs.readFileSync(commitFilePath()).toString()
  stripOut = text.indexOf "\n# Please enter"
  text = text.slice(0, stripOut)
  fs.writeFileSync commitFilePath(), text, flag: 'w+'

module.exports = gitCommit