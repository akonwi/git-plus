Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'

git = require '../git'
GitShow = require '../models/git-show'

module.exports =
class LogListView extends SelectListView

  currentFile = ->
    git.relativize atom.workspace.getActiveEditor()?.getPath()

  showCommitFilePath = ->
    Path.join Os.tmpDir(), "atom_git_plus_commit.diff"

  initialize: (@data, @onlyCurrentFile) ->
    super
    @show()
    @parseData()

  parseData: ->
    @data = @data.split("\n")[...-1]
    @setItems(
      for item in @data when item != ''
        tmp = item.match /([\w\d]{7});\|(.*);\|(.*);\|(.*)/
        {hash: tmp?[1], author: tmp?[2], title: tmp?[3], time: tmp?[4]}
    )
    @focusFilterEditor()

  getFilterKey: -> 'title'

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

  cancelled: -> @hide()

  hide: ->
    @panel?.destroy()

  viewForItem: (commit) ->
    $$ ->
      @li =>
        @div class: 'text-highlight text-huge', commit.title
        @div class: '', "#{commit.hash} by #{commit.author}"
        @div class: 'text-info', commit.time

  confirmed: ({hash}) ->
    GitShow(hash, currentFile() if @onlyCurrentFile)
