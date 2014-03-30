PathWatcher = require 'pathwatcher'
File = PathWatcher.File
{BufferedProcess} = require 'atom'

currentPane = null
dir = ''
commitFilePath = -> dir + '/.git/COMMIT_EDITMSG'
commitEditor = null

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
      alert data.toString()
  })

# FIXME?: maybe I shouldn't use the COMMIT file in .git/
# TODO?: Strip out the git tips that 'git status' prints in message
prepFile = (text) ->
  PathWatcher.closeAllWatchers()
  # format the text to be ignored in the commit message
  text = text.replace(/\n/g, "\n# ")
  # in order to make sure each line doesn't start with a space, the preceding
  #   line should end with a backslash
  new File(commitFilePath())
    .write " \n\
     # Please enter the commit message for your changes. Lines starting\n\
     # with '#' will be ignored, and an empty message aborts the commit.\n\
     # #{text}"
  showFile()

showFile = ->
  atom.workspace
    .open(commitFilePath(), split: 'right', activatePane: true)
    # ::open returns a promise resolving to the editor
    .done (editor) -> commitEditor = editor
  PathWatcher.watch commitFilePath(), (event) =>
    # only commit if there isn't already an editor for the commitFile
    commit() if event is 'change'

commit = ->
  PathWatcher.closeAllWatchers()
  cleanFile()
  new BufferedProcess({
    command: 'git'
    args: ['commit', "--file=#{commitFilePath()}"]
    options:
      cwd: dir
    stdout: (data) =>
      atom.workspace.destroyActivePane()
      currentPane.activate()
      # reset editor for commitFile
      currentEditor = null
    stderror: (data) =>
      # there shouldn't be an error so make a fuss
      alert data.toString()
      atom.beep()
  })

cleanFile = ->
  file = new File(commitFilePath())
  text = file.readSync()
  stripOut = text.indexOf "\n# Please enter"
  text = text.slice(0, stripOut)
  file.write text

module.exports = gitCommit
