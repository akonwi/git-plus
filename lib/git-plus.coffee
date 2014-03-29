{File} = require 'pathwatcher'
{BufferedProcess} = require 'atom'
StatusView = require './status-view'

module.exports =
  activate: (state) ->
    @dir = atom.project.getRepo().getWorkingDirectory()
    atom.workspaceView.command "git-plus:commit", => @gitStatus()

  deactivate: ->
    # @gitPlusView.destroy()

  serialize: ->
    # gitPlusViewState: @gitPlusView.serialize()

  # TODO: use workspace.getActivePane()
  #  split the pane and add the statusView
  gitStatus: ->
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
  prepFile: (text) ->
    # format the text to be ignored in the commit message
    text = text.replace(/\n/g, "\n# ")
    path = @dir + '/.git/COMMIT_EDITMSG'
    # in order to make sure each line doesn't start with a space, the preceding
    #   line should end with a backslash
    new File(path)
      .write " \n\
       # Please enter the commit message for your changes. Lines starting\n\
       # with '#' will be ignored, and an empty message aborts the commit.\n\
       # #{text}"
    @showFile()

  showFile: ->
    atom.workspace.open @dir + '/.git/COMMIT_EDITMSG', split: 'right', activatePane: true
