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
    return if @assignId() isnt 1
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
          if @amend is '' then @cleanup() else @undoAmend()

  commit: ->
    args = ['commit', '--cleanup=strip', "--file=#{@filePath()}"]
    args.push '--amend' if @amend isnt ''
    @amend = ''
    git.cmd
      args: args,
      options:
        cwd: @dir()
      stdout: (data) =>
        new StatusView(type: 'success', message: data)
        if atom.workspace.getActivePane().getItems().length > 1
          atom.workspace.destroyActivePaneItem()
        else
          atom.workspace.destroyActivePane()
        atom.project.getRepo()?.refreshStatus()
        @currentPane.activate()

  undoAmend: ->
    git.cmd
      args: ['reset', 'HEAD@{1}'],
      stdout: =>
        new StatusView(type: 'error', message: 'Commit amend aborted!')
        @cleanup()

  cleanup: ->
    Model.resetNextInstanceId()
    @destroy()
    @currentPane.activate()
    try fs.unlinkSync @filePath()
