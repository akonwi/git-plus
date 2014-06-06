{$$, BufferedProcess, SelectListView} = require 'atom'
OutputView = require './output-view'
StatusView = require './status-view'
GitShow = require './git-show'

module.exports =
class TagView extends SelectListView

  dir = ->
    atom.project.getRepo().getWorkingDirectory()

  initialize: (@tag) ->
    super
    @addClass 'overlay from-top'
    @parseData()

  parseData: ->
    items = []
    items.push {tag: @tag, cmd: 'Show', description: 'git show'}
    items.push {tag: @tag, cmd: 'Checkout', description: 'git checkout'}
    items.push {tag: @tag, cmd: 'Verify', description: 'git tag --verify'}
    items.push {tag: @tag, cmd: 'Delete', description: 'git tag --delete'}

    @setItems items
    atom.workspaceView.append this
    @focusFilterEditor()

  viewForItem: ({tag, cmd, description}) ->
    $$ ->
      @li =>
        @div class: 'text-highlight', cmd
        @div class: 'text-warning', "#{description} #{tag}"

  getFilterKey: -> 'cmd'

  confirmed: ({tag, cmd}) ->
    @cancel()
    switch cmd
      when 'Show'
        GitShow(tag)
        return
      when 'Checkout'
        args = ['checkout', tag]
      when 'Verify'
        args = ['tag', '--verify', tag]
      when 'Delete'
        args = ['tag', '--delete', tag]

    new BufferedProcess
      command: 'git'
      args: args
      options:
        cwd: dir()
      stdout: (data) ->
        new StatusView(type: 'success', message: data.toString())
      stderr: (data) ->
        new StatusView(type: 'alert', message: data.toString())
