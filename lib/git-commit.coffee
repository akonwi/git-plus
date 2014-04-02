fs = require 'fs-plus'
{BufferedProcess} = require 'atom'
StatusView = require './status-view'

currentPane = null
dir = ''
commitFilePath = -> dir + '/.git/COMMIT_EDITMSG'
commitEditor = null
watcher = null

gitCommit = ->
  currentPane = atom.workspace.getActivePane()
  dir = atom.project.getRepo().getWorkingDirectory()
  new BufferedProcess({
    command: 'git'
    args: ['status']
    options:
      cwd: dir
    stdout: (data) =>
      prepFile data.toString()
    stderror: (data) =>
      new StatusView(type: 'alert', message: data.toString())
  })

# FIXME?: maybe I shouldn't use the COMMIT file in .git/
# TODO?: Strip out the git tips that 'git status' prints in message
prepFile = (text) ->
  watcher.close() if watcher?
  # format the text to be ignored in the commit message
  text = text.replace(/\n/g, "\n# ")
  # in order to make sure each line doesn't start with a space, the preceding
  #   line should end with a backslash
  fs.writeFileSync commitFilePath(),
    " \n\
      # Please enter the commit message for your changes. Lines starting\n\
      # with '#' will be ignored, and an empty message aborts the commit.\n\
      # #{text}",
    flag: 'w+'
  showFile()

showFile = ->
  atom.workspace
    .open(commitFilePath(), split: 'right', activatePane: true)
    # ::open returns a promise resolving to the editor
    .done (editor) -> commitEditor = editor
  watcher = fs.watch commitFilePath(), (event) =>
    commit() if event is 'change'

commit = ->
  watcher.close()
  cleanFile()
  new BufferedProcess({
    command: 'git'
    args: ['commit', "--file=#{commitFilePath()}"]
    options:
      cwd: dir
    stdout: (data) =>
      atom.workspace.destroyActivePane()
      currentPane.activate()
      new StatusView(type: 'success', message: data.toString())
      # reset editor for commitFile
      currentEditor = null
      atom.workspaceView.trigger 'core:save'
    stderror: (data) =>
      new StatusView(type: 'alert', message: data.toString())
      atom.beep()
  })

cleanFile = ->
  text = fs.readFileSync(commitFilePath()).toString()
  stripOut = text.indexOf "\n# Please enter"
  text = text.slice(0, stripOut)
  fs.writeFileSync commitFilePath(), text, flag: 'w+'

module.exports = gitCommit
