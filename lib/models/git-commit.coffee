fs = require 'fs-plus'
path = require 'path'
os = require 'os'
{Model} = require 'theorist'

git = require '../git'
StatusView = require '../views/status-view'

module.exports =
class GitCommit extends Model

  file: ->
    # git puts submodules in a `.git` folder named after the child repo
    if @submodule ?= git.getSubmodule()
      'COMMIT_EDITMSG'
    else
      '.git/COMMIT_EDITMSG'

  dir: ->
    # path is different for submodules
    if @submodule ?= git.getSubmodule()
      @submodule.getPath()
    else
      atom.project.getRepo()?.getWorkingDirectory() ? atom.project.getPath()

  filePath: -> path.join @dir(), @file()
  currentPane: atom.workspace.getActivePane()

  constructor: (@amend='') ->
    super

    # This prevents atom from creating more than one Editor to edit the commit
    # message.
    return if @assignId() isnt 1

    # This sets @isAmending to check if we are amending right now.
    @isAmending = @amend.length > 0

    git.stagedFiles (files) =>
      if @amend isnt '' or files.length >= 1
        git.cmd
          args: ['status'],
          stdout: (data) => @prepFile data
      else
        @cleanup()
        new StatusView(type: 'error', message: 'Nothing to commit.')

  # FIXME?: maybe I shouldn't use the COMMIT file in .git/
  prepFile: (status) ->
    # format the status to be ignored in the commit message
    status = status.replace(/\s*\(.*\)\n/g, '')
    status = status.trim().replace(/\n/g, "\n# ")
    fs.writeFileSync @filePath(),
       """#{@amend}
        # Please enter the commit message for your changes. Lines starting
        # with '#' will be ignored, and an empty message aborts the commit.
        #
        # #{status}"""
    @showFile()

  showFile: ->
    split = if atom.config.get('git-plus.openInPane') then atom.config.get('git-plus.splitPane')
    atom.workspace
      .open(@filePath(), split: split, activatePane: true, searchAllPanes: true)
      .done ({buffer}) =>
        @subscribe buffer, 'saved', =>
          @commit()
        @subscribe buffer, 'destroyed', =>
          if @isAmending then @undoAmend() else @cleanup()

  commit: ->
    args = ['commit', '--cleanup=strip', "--file=#{@filePath()}"]
    git.cmd
      args: args,
      options:
        cwd: @dir()
      stdout: (data) =>
        new StatusView(type: 'success', message: data)
        # Set @isAmending to false since it succeeded.
        @isAmending = false

        # Destroying the active EditorView will trigger our cleanup method.
        @destroyActiveEditorView()

        # Refreshing the atom repo status to refresh things like TreeView and
        # diff gutter.
        atom.project.getRepo()?.refreshStatus()

        # Activate the former active pane.
        @currentPane.activate()

        # Refresh git index to prevent bugs on our methods.
        git.refresh()

      stderr: (err) =>
        if @isAmending then @undoAmend() else @cleanup()

  destroyActiveEditorView: ->
    if atom.workspace.getActivePane().getItems().length > 1
      atom.workspace.destroyActivePaneItem()
    else
      atom.workspace.destroyActivePane()

  undoAmend: (err='') ->
    git.cmd
      args: ['reset', 'ORIG_HEAD'],
      stdout: ->
        new StatusView(type: 'error', message: "#{err+': '}Commit amend aborted!")
      stderr: ->
        new StatusView(type: 'error', message: 'ERROR! Undoing the amend failed! Please fix your repository manually!')
      exit: =>
        # Set @isAmending to false since the amending process has been aborted.
        @isAmending = false

        # Destroying the active EditorView will trigger our cleanup method.
        @destroyActiveEditorView()

  cleanup: ->
    Model.resetNextInstanceId()
    @destroy()
    @currentPane.activate()
    try fs.unlinkSync @filePath()
