{$$, BufferedProcess, SelectListView} = require 'atom'
StatusView = require './status-view'

module.exports =
class ListView extends SelectListView
  initialize: (@data) ->
    super
    @addClass 'overlay from-top'
    @parseData()

  parseData: ->
    items = @data.split("\n")
    branches = []
    for item in items
      item = item.replace(/\s/g, '')
      unless item is ''
        branches.push {name: item}
    @setItems branches
    atom.workspaceView.append this
    @focusFilterEditor()

  getFilterKey: -> 'name'

  viewForItem: ({name}) ->
    current = false
    if name.startsWith "*"
      name = name.slice(1)
      current = true
    # $$ is an alias for View.render
    $$ ->
      @li name, =>
        @div class: 'pull-right', =>
          @span('Current') if current


  confirmed: ({name}) ->
    @changeTo name
    @cancel()

  changeTo: (branch) ->
    dir = atom.project.getRepo().getWorkingDirectory()
    new BufferedProcess
      command: 'git'
      args: ['checkout', branch]
      options:
        cwd: dir
      stdout: (data) ->
        new StatusView(type: 'success', message: data.toString())
      stderr: (data) ->
        new StatusView(type: 'alert', message: data.toString())
