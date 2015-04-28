{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
Path = require 'path'
os = require 'os'

git = require '../git'
StatusView = require '../views/status-view'
GitPush = require './git-push'

module.exports =
class GitCommit
  # Public: Helper method to set the commentchar to be used in
  #   the commit message
  setCommentChar: (char) ->
    if char is '' then char = '#'
    @commentchar = char

  # Public: Helper method to return the current working directory.
  #
  # Returns: The cwd as a String.
  dir: ->
    # path is different for submodules
    if @submodule ?= git.getSubmodule()
      @submodule.getWorkingDirectory()
    else
      @repo.getWorkingDirectory()

  # Public: Helper method to join @dir() and filename to use it with fs.
  #
  # Returns: The full path to our COMMIT_EDITMSG file as {String}
  filePath: -> Path.join(@dir(), 'COMMIT_EDITMSG')

  constructor: (@repo, {@amend, @andPush}={}) ->
    @currentPane = atom.workspace.getActivePane()
    @disposables = new CompositeDisposable

    # Check if we are amending right now.
    @amend ?= ''
    @isAmending = @amend.length > 0

    # Load the commentchar from git config, defaults to '#'
    git.cmd
      args: ['config', '--get', 'core.commentchar'],
      stdout: (data) =>
        @setCommentChar data.trim()
      stderr: =>
        @setCommentChar '#'

    git.stagedFiles @repo, (files) =>
      if @amend isnt '' or files.length >= 1
        git.cmd
          args: ['status'],
          cwd: @repo.getWorkingDirectory()
          stdout: (data) => @prepFile data
      else
        @cleanup()
        new StatusView(type: 'error', message: 'Nothing to commit.')

  # Public: Prepares our commit message file by writing the status and a
  #         possible amend message to it.
  #
  # status - The current status as {String}.
  prepFile: (status) ->
    # format the status to be ignored in the commit message
    status = status.replace(/\s*\(.*\)\n/g, '')
    status = status.trim().replace(/\n/g, "\n#{@commentchar} ")
    fs.writeFileSync @filePath(),
      """#{@amend}
      #{@commentchar} Please enter the commit message for your changes. Lines starting
      #{@commentchar} with '#{@commentchar}' will be ignored, and an empty message aborts the commit.
      #{@commentchar}
      #{@commentchar} #{status}"""
    @showFile()

  # Public: Helper method to open the commit message file and to subscribe the
  #         'saved' and `destroyed` events of the underlaying text-buffer.
  showFile: ->
    split = if atom.config.get('git-plus.openInPane') then atom.config.get('git-plus.splitPane')
    atom.workspace
      .open(@filePath(), split: split, searchAllPanes: true)
      .done (textBuffer) =>
        if textBuffer?
          @disposables.add textBuffer.onDidSave => @commit()
          @disposables.add textBuffer.onDidDestroy =>
            if @isAmending then @undoAmend() else @cleanup()

  # Public: When the user is done editing the commit message an saves the file
  #         this method gets invoked and commits the changes.
  commit: ->
    args = ['commit', '--cleanup=strip', "--file=#{@filePath()}"]
    git.cmd
      args: args,
      options:
        cwd: @dir()
      stdout: (data) =>
        new StatusView(type: 'success', message: data)
        if @andPush
          new GitPush(@repo)
        # Set @isAmending to false since it succeeded.
        @isAmending = false
        # Destroying the active EditorView will trigger our cleanup method.
        @destroyActiveEditorView()
        # Refreshing the atom repo status to refresh things like TreeView and
        # diff gutter.
        @repo.refreshStatus()
        # Activate the former active pane.
        @currentPane.activate() if @currentPane.alive
        # Refresh git index to prevent bugs on our methods.
        git.refresh()

      stderr: (err) =>
        # Destroying the active EditorView will trigger our cleanup method.
        @destroyActiveEditorView()

  # Public: Destroys the active EditorView to trigger our cleanup method.
  destroyActiveEditorView: ->
    if atom.workspace.getActivePane().getItems().length > 1
      atom.workspace.destroyActivePaneItem()
    else
      atom.workspace.destroyActivePane()

  # Public: Undo the amend
  #
  # err - The error message as {String}.
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
        @cleanup()

  # Public: Cleans up after the EditorView gets destroyed.
  cleanup: ->
    @currentPane.activate() if @currentPane.alive
    @disposables.dispose()
    @repo.destroy if @repo.destroyable
    try fs.unlinkSync @filePath()
