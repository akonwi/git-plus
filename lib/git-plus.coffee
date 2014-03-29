PathWatcher = require 'pathwatcher'
File = PathWatcher.File
{BufferedProcess} = require 'atom'
StatusView = require './status-view'

module.exports =
  currentPane: null
  dir: ''
  commitFilePath: -> @dir + '/.git/COMMIT_EDITMSG'

  activate: (state) ->
    @dir = atom.project.getRepo().getWorkingDirectory()
    @commitFilePath()
    atom.workspaceView.command "git-plus:commit", => @gitStatus()

  deactivate: ->
    # @gitPlusView.destroy()

  serialize: ->
    # gitPlusViewState: @gitPlusView.serialize()

  gitStatus: ->
    @currentPane = atom.workspace.getActivePane()
    process = new BufferedProcess({
      command: 'git'
      args: ['status']
      options:
        cwd: @dir
      stdout: (data) =>
        @prepFile data.toString()
      stderror: (data) =>
        alert data.toString()
    })
      # @statusView = new StatusView()
      #   .find('div.message').html(data.toString())

  # FIXME: maybe I shouldn't use the COMMIT file in .git/
  # TODO: Strip out the git tips that 'git status' prints in message
  prepFile: (text) ->
    # format the text to be ignored in the commit message
    text = text.replace(/\n/g, "\n# ")
    # in order to make sure each line doesn't start with a space, the preceding
    #   line should end with a backslash
    new File(@commitFilePath())
      .write " \n\
       # Please enter the commit message for your changes. Lines starting\n\
       # with '#' will be ignored, and an empty message aborts the commit.\n\
       # #{text}"
    @showFile()

  showFile: ->
    atom.workspace.open @commitFilePath(), split: 'right', activatePane: true
    PathWatcher.watch @commitFilePath(), (event) =>
      if event is 'change'
        @commit()

  commit: ->
    process = new BufferedProcess({
      command: 'git'
      args: ['commit', "--file=#{@commitFilePath()}"]
      options:
        cwd: @dir
      stdout: (data) =>
        PathWatcher.closeAllWatchers()
        atom.workspace.destroyActivePane()
        @currentPane.activate()
      stderror: (data) =>
        alert data.toString()
    })
