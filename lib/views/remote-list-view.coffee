{$$, SelectListView} = require 'atom-space-pen-views'

git = require '../git'
_pull = require '../models/_pull'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'
PullBranchListView = require './pull-branch-list-view'

experimentalFeaturesEnabled = () ->
  gitPlus = atom.config.get('git-plus')
  gitPlus.alwaysPullFromUpstream and gitPlus.experimental

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
    if experimentalFeaturesEnabled()
      _pull @repo, extraArgs: [@extraArgs]
    else
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
        @pull(name).then => @execute name
      else
        @execute name
    else if @mode is 'push -u'
      @pushAndSetUpstream name
    else
      @execute name
    @cancel()

  execute: (remote='', extraArgs='') ->
    view = OutputViewManager.create()
    args = [@mode]
    if extraArgs.length > 0
      args.push extraArgs
    args = args.concat([remote, @tag]).filter((arg) -> arg isnt '')
    message = "#{@mode[0].toUpperCase()+@mode.substring(1)}ing..."
    startMessage = notifier.addInfo message, dismissable: true
    git.cmd(args, cwd: @repo.getWorkingDirectory(), {color: true})
    .then (data) ->
      if data isnt ''
        view.setContent(data).finish()
      startMessage.dismiss()
    .catch (data) =>
      if data isnt ''
        view.setContent(data).finish()
      startMessage.dismiss()

  pushAndSetUpstream: (remote='') ->
    view = OutputViewManager.create()
    args = ['push', '-u', remote, 'HEAD'].filter((arg) -> arg isnt '')
    message = "Pushing..."
    startMessage = notifier.addInfo message, dismissable: true
    git.cmd(args, cwd: @repo.getWorkingDirectory(), {color: true})
    .then (data) ->
      if data isnt ''
        view.setContent(data).finish()
      startMessage.dismiss()
    .catch (data) =>
      if data isnt ''
        view.setContent(data).finish()
      startMessage.dismiss()
