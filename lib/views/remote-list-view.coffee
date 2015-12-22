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

  pull: (remoteName) ->
    git.cmd(['branch', '-r'], cwd: @repo.getWorkingDirectory())
    .then (data) =>
      new PullBranchListView(@repo, data, remoteName, @extraArgs).result

  confirmed: ({name}) ->
    if @mode is 'pull'
      @pull name
    else if @mode is 'fetch-prune'
      @mode = 'fetch'
      @execute name, '--prune'
    else if @mode is 'push'
      pullOption = atom.config.get 'git-plus.pullBeforePush'
      @extraArgs = if pullOption?.includes '--rebase' then '--rebase' else ''
      unless pullOption? and pullOption is 'no'
        @pull(name)
        .then => @execute name
        .catch ->
      else
        @execute name
    else
      @execute name
    @cancel()

  execute: (remote='', extraArgs='') ->
    view = OutputViewManager.new()
    args = [@mode]
    if extraArgs.length > 0
      args.push extraArgs
    args = args.concat([remote, @tag]).filter((arg) -> arg isnt '')
    command = atom.config.get('git-plus.gitPath') ? 'git'
    message = "#{@mode[0].toUpperCase()+@mode.substring(1)}ing..."
    startMessage = notifier.addInfo message, dismissable: true
    git.cmd(args, cwd: @repo.getWorkingDirectory())
    .then (data) ->
      if data isnt ''
        view.addLine(data).finish()
      startMessage.dismiss()
    .catch (data) =>
      git.cmd([@mode, '-u', remote, 'HEAD'], cwd: @repo.getWorkingDirectory())
      .then (message) ->
        view.addLine(message).finish()
        startMessage.dismiss()
