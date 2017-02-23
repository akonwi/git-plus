{$$, SelectListView} = require 'atom-space-pen-views'

git = require '../git'
_pull = require '../models/_pull'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'
RemoteBranchListView = require './remote-branch-list-view'

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

  hide: -> @panel?.destroy()

  viewForItem: ({name}) ->
    $$ ->
      @li name

  pull: (remoteName) ->
    if atom.config.get('git-plus.remoteInteractions.promptForBranch')
      git.cmd(['branch', '--no-color', '-r'], cwd: @repo.getWorkingDirectory())
      .then (data) =>
        new Promise (resolve, reject) =>
          new RemoteBranchListView data, remoteName, ({name}) =>
            branchName = name.substring(name.indexOf('/') + 1)
            view = OutputViewManager.create()
            startMessage = notifier.addInfo "Pulling...", dismissable: true
            args = ['pull'].concat(@extraArgs, remoteName, branchName).filter((arg) -> arg isnt '')
            git.cmd(args, cwd: @repo.getWorkingDirectory(), {color: true})
            .then (data) =>
              resolve branchName
              view.setContent(data).finish()
              startMessage.dismiss()
              git.refresh @repo
            .catch (error) =>
              reject()
              view.setContent(error).finish()
              startMessage.dismiss()
    else
      _pull @repo, extraArgs: @extraArgs

  confirmed: ({name}) ->
    if @mode is 'pull'
      @pull name
    else if @mode is 'fetch-prune'
      @mode = 'fetch'
      @execute name, '--prune'
    else if @mode is 'push'
      pullBeforePush = atom.config.get('git-plus.remoteInteractions.pullBeforePush')
      @extraArgs = '--rebase' if pullBeforePush and atom.config.get('git-plus.remoteInteractions.pullRebase')
      if pullBeforePush
        @pull(name).then (branch) => @execute name, null, branch
      else
        @execute name
    else if @mode is 'push -u'
      @pushAndSetUpstream name
    else
      @execute name
    @cancel()

  execute: (remote='', extraArgs='', branch) ->
    if atom.config.get('git-plus.remoteInteractions.promptForBranch')
      if branch?
        view = OutputViewManager.create()
        args = [@mode]
        if extraArgs.length > 0
          args.push extraArgs
        args = args.concat([remote, branch])
        message = "#{@mode[0].toUpperCase()+@mode.substring(1)}ing..."
        startMessage = notifier.addInfo message, dismissable: true
        git.cmd(args, cwd: @repo.getWorkingDirectory(), {color: true})
        .then (data) =>
          if data isnt ''
            view.setContent(data).finish()
          startMessage.dismiss()
          git.refresh @repo
        .catch (data) =>
          if data isnt ''
            view.setContent(data).finish()
          startMessage.dismiss()
      else
        git.cmd(['branch', '--no-color', '-r'], cwd: @repo.getWorkingDirectory())
        .then (data) =>
          new RemoteBranchListView data, remote, ({name}) =>
            branchName = name.substring(name.indexOf('/') + 1)
            view = OutputViewManager.create()
            startMessage = notifier.addInfo "Pushing...", dismissable: true
            args = ['push'].concat(extraArgs, remote, branchName).filter((arg) -> arg isnt '')
            git.cmd(args, cwd: @repo.getWorkingDirectory(), {color: true})
            .then (data) =>
              view.setContent(data).finish()
              startMessage.dismiss()
              git.refresh @repo
            .catch (error) =>
              view.setContent(error).finish()
              startMessage.dismiss()
    else
      view = OutputViewManager.create()
      args = [@mode]
      if extraArgs.length > 0
        args.push extraArgs
      args = args.concat([remote, @tag]).filter((arg) -> arg isnt '')
      message = "#{@mode[0].toUpperCase()+@mode.substring(1)}ing..."
      startMessage = notifier.addInfo message, dismissable: true
      git.cmd(args, cwd: @repo.getWorkingDirectory(), {color: true})
      .then (data) =>
        if data isnt ''
          view.setContent(data).finish()
        startMessage.dismiss()
        git.refresh @repo
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
