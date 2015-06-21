{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'

git = require '../git'
OutputView = require './output-view'
PullBranchListView = require './pull-branch-list-view'

module.exports =
class ListView extends SelectListView
  initialize: (@repo, @data, {@mode, @tag, @extraArgs}) ->
    super
    @tag ?= ''
    @extraArgs ?= []
    @show()
    @parseData()

  parseData: ->
    items = @data.split("\n")
    remotes = []
    for item in items
      remotes.push {name: item} unless item is ''
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
      git.cmd
        args: ['branch', '-r'],
        cwd: @repo.getWorkingDirectory()
        stdout: (data) => new PullBranchListView(@repo, data, name, @extraArgs)
    else if @mode is 'fetch-prune'
      @mode = 'fetch'
      @execute name, '--prune'
    else
      @execute name
    @cancel()

  execute: (remote, extraArgs='') ->
    view = new OutputView()
    args = [@mode]
    if extraArgs.length > 0
      args.push extraArgs
    args = args.concat([remote, @tag])
    git.cmd
      args: args
      cwd: @repo.getWorkingDirectory()
      stdout: (data) -> view.addLine(data.toString())
      stderr: (data) -> view.addLine(data.toString())
      exit: (code) =>
        if code is 128
          view.reset()
          git.cmd
            args: [@mode, '-u', remote, 'HEAD']
            cwd: @repo.getWorkingDirectory()
            stdout: (data) -> view.addLine(data.toString())
            stderr: (data) -> view.addLine(data.toString())
            exit: (code) -> view.finish()
        else
          view.finish()
