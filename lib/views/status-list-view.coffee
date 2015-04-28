{$$, SelectListView} = require 'atom-space-pen-views'
fs = require 'fs'
Path = require 'path'
git = require '../git'
GitDiff = require '../models/git-diff'
StatusView = require '../views/status-view'

module.exports =
class StatusListView extends SelectListView
  initialize: (@repo, @data, {@onlyCurrentFile}={}) ->
    super
    @show()
    @branch = @data[0]
    @setItems @parseData @data[...-1]
    @focusFilterEditor()

  parseData: (files) ->
    for line in files when /^([ MADRCU?!]{2})\s{1}(.*)/.test line
      line = line.match /^([ MADRCU?!]{2})\s{1}(.*)/
      {type: line[1], path: line[2]}

  getFilterKey: -> 'path'

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @storeFocusedElement()

  cancelled: -> @hide()

  hide: -> @panel?.destroy()

  viewForItem: ({type, path}) ->
    getIcon = (s) ->
      return 'status-added icon icon-diff-added' if s[0] is 'A'
      return 'status-removed icon icon-diff-removed' if s[0] is 'D'
      return 'status-renamed icon icon-diff-renamed' if s[0] is 'R'
      return 'status-modified icon icon-diff-modified' if s[0] is 'M' or s[1] is 'M'
      return ''

    $$ ->
      @li =>
        @div
          class: 'pull-right highlight'
          style: 'white-space: pre-wrap; font-family: monospace'
          type
        @span class: getIcon(type)
        @span path

  confirmed: ({type, path}) ->
    @cancel()
    if type is '??'
      git.add @repo, file: path
    else
      openFile = confirm("Open #{path}?")
      fullPath = Path.join(@repo.getWorkingDirectory(), path)

      fs.stat fullPath, (err, stat) =>
        if err
          new StatusView(type: 'error', message: err.message)
        else
          isDirectory = stat?.isDirectory()
          if openFile
            if isDirectory
              atom.open(pathsToOpen: fullPath, newWindow: true)
            else
              atom.workspace.open(fullPath)
          else
            GitDiff(@repo, file: path)
