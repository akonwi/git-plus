{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
Path = require 'flavored-path'
os = require 'os'

git = require '../git'
notifier = require '../notifier'
GitPush = require './git-push'

module.exports =
class GitCommit
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
  filePath: -> Path.join(@repo.getPath(), 'COMMIT_EDITMSG')

  constructor: (@repo, {@amend, @andPush, @stageChanges}={}) ->
    @currentPane = atom.workspace.getActivePane()
    @disposables = new CompositeDisposable

    # Check if we are amending right now.
    @amend ?= ''
    @isAmending = @amend.length > 0

    # Load the commentchar from git config, defaults to '#'
    @commentchar = '#'
    git.cmd
      args: ['config', '--get', 'core.commentchar'],
      stdout: (data) =>
        if data.trim() isnt ''
          @commentchar = data.trim()

    if @stageChanges
      git.add @repo,
        update: true,
        exit: (code) => @getStagedFiles()
    else
      @getStagedFiles()

  getStagedFiles: ->
    git.stagedFiles @repo, (files) =>
      if @amend isnt '' or files.length >= 1
        git.cmd
          args: ['status'],
          cwd: @repo.getWorkingDirectory()
          stdout: (data) => @prepFile data
      else
        @cleanup()
        notifier.addInfo 'Nothing to commit.'

  # Public: Prepares our commit message file by writing the status and a
  #         possible amend message to it.
  #
  # status - The current status as {String}.
  prepFile: (status) ->
    # format the status to be ignored in the commit message
    status = status.replace(/\s*\(.*\)\n/g, "\n")
    status = status.trim().replace(/\n/g, "\n#{@commentchar} ")

    @getTemplate().then (template) =>
      fs.writeFileSync @filePath(),
        """#{ if @amend.length > 0 then @amend else template}
        #{@commentchar} Please enter the commit message for your changes. Lines starting
        #{@commentchar} with '#{@commentchar}' will be ignored, and an empty message aborts the commit.
        #{@commentchar}
        #{@commentchar} #{status}"""
      @showFile()

  getTemplate: ->
    new Promise (resolve, reject) ->
      git.cmd
        args: ['config', '--get', 'commit.template']
        stdout: (data) =>
          resolve (if data.trim() isnt '' then fs.readFileSync(Path.get(data.trim())) else '')

  # Public: Helper method to open the commit message file and to subscribe the
  #         'saved' and `destroyed` events of the underlaying text-buffer.
  showFile: ->
    atom.workspace
      .open(@filePath(), searchAllPanes: true)
      .done (textEditor) =>
        if atom.config.get('git-plus.openInPane')
          @splitPane(atom.config.get('git-plus.splitPane'), textEditor)
        else
          @disposables.add textEditor.onDidSave => @commit()
          @disposables.add textEditor.onDidDestroy =>
            if @isAmending then @undoAmend() else @cleanup()

  splitPane: (splitDir, oldEditor) ->
    pane = atom.workspace.paneForURI(@filePath())
    options = { copyActiveItem: true }
    hookEvents = (textEditor) =>
      oldEditor.destroy()
      @disposables.add textEditor.onDidSave => @commit()
      @disposables.add textEditor.onDidDestroy =>
        if @isAmending then @undoAmend() else @cleanup()

    directions =
      left: =>
        pane = pane.splitLeft options
        hookEvents(pane.getActiveEditor())
      right: ->
        pane = pane.splitRight options
        hookEvents(pane.getActiveEditor())
      up: ->
        pane = pane.splitUp options
        hookEvents(pane.getActiveEditor())
      down: ->
        pane = pane.splitDown options
        hookEvents(pane.getActiveEditor())
    directions[splitDir]()

  # Public: When the user is done editing the commit message an saves the file
  #         this method gets invoked and commits the changes.
  commit: ->
    args = ['commit', '--cleanup=strip', "--file=#{@filePath()}"]
    git.cmd
      args: args,
      options:
        cwd: @dir()
      stdout: (data) =>
        notifier.addSuccess data
        if @andPush
          new GitPush(@repo)
        @isAmending = false
        @destroyCommitEditor()
        # Activate the former active pane.
        @currentPane.activate() if @currentPane.alive
        git.refresh()

      stderr: (err) => @destroyCommitEditor()

  destroyCommitEditor: ->
    @cleanup()
    atom.workspace.getPanes().some (pane) ->
      pane.getItems().some (paneItem) ->
        if paneItem?.getURI?()?.includes 'COMMIT_EDITMSG'
          if pane.getItems().length is 1
            pane.destroy()
          else
            paneItem.destroy()
          return true

  # Public: Undo the amend
  #
  # err - The error message as {String}.
  undoAmend: (err='') ->
    git.cmd
      args: ['reset', 'ORIG_HEAD'],
      stdout: ->
        notifier.addError "#{err}: Commit amend aborted!"
      stderr: ->
        notifier.addError 'ERROR! Undoing the amend failed! Please fix your repository manually!'
      exit: =>
        # Set @isAmending to false since the amending process has been aborted.
        @isAmending = false

        # Destroying the active EditorView will trigger our cleanup method.
        @destroyCommitEditor()

  # Public: Cleans up after the EditorView gets destroyed.
  cleanup: ->
    @currentPane.activate() if @currentPane.alive
    @disposables.dispose()
    try fs.unlinkSync @filePath()
