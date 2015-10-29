{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'

git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'
PullBranchListView = require './pull-branch-list-view'

module.exports =
class ListView extends SelectListView
  initialize: (@repo, @data, {@mode, @tag, @extraArgs}={}) ->
    super
    @tag ?= ''
    @extraArgs ?= []
    @show()
    @parseData()
    @result = new Promise (@resolve, @reject) =>

  parseData: ->
    items = @data.split("\n")
    remotes = items.filter((item) -> item isnt '').map (item) -> { name: item }
    if remotes.length is 1
      @confirmed remotes[0]
    else
      @setItems remotes
      @focusFilterEditor()

  getFilterKey: -> 'name'

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

  cancelled: -> @hide()

  hide: ->
    @panel?.destroy()

  viewForItem: ({name}) ->
    $$ ->
      @li name

  confirmed: ({name}) ->
    if @mode is 'pull'
      git.cmd(['branch', '-r'], cwd: @repo.getWorkingDirectory())
      .then (data) => new PullBranchListView(@repo, data, name, @extraArgs, @resolve)
    else if @mode is 'fetch-prune'
      @mode = 'fetch'
      @execute name, '--prune'
    else
      @execute name
    @cancel()

  execute: (remote, extraArgs='') ->
    view = OutputViewManager.new()
    args = [@mode]
    if extraArgs.length > 0
      args.push extraArgs
    args = args.concat([remote, @tag])
    command = atom.config.get('git-plus.gitPath') ? 'git'
    message = "#{@mode[0].toUpperCase()+@mode.substring(1)}ing..."
    startMessage = notifier.addInfo message, dismissable: true
    new BufferedProcess
      command: command
      args: args
      options:
        cwd: @repo.getWorkingDirectory()
      stdout: (data) -> view.addLine(data.toString())
      stderr: (data) -> view.addLine(data.toString())
      exit: (code) =>
        if code is 128
          view.reset()
          new BufferedProcess
            command: command
            args: [@mode, '-u', remote, 'HEAD']
            options:
              cwd: @repo.getWorkingDirectory()
            stdout: (data) -> view.addLine(data.toString())
            stderr: (data) -> view.addLine(data.toString())
            exit: (code) ->
              view.finish()
              startMessage.dismiss()
        else
          view.finish()
          startMessage.dismiss()
