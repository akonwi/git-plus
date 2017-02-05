{$$, SelectListView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
git = require '../git'
notifier = require '../notifier'
BranchListView = require './branch-list-view'
GitDiff = require '../models/git-diff'
Path = require 'path'
RevisionView = require './git-revision-view'

disposables = new CompositeDisposable

showFile = (filePath) ->
  if atom.config.get('git-plus.general.openInPane')
    splitDirection = atom.config.get('git-plus.general.splitPane')
    atom.workspace.getActivePane()["split#{splitDirection}"]()
  atom.workspace.open(filePath)

prepFile = (text, filePath) ->
  new Promise (resolve, reject) ->
    if text?.length is 0
      reject nothingToShow
    else
      fs.writeFile filePath, text, flag: 'w+', (err) ->
        if err then reject err else resolve true

module.exports =
class DiffBranchFilesListView extends BranchListView
  initialize: (@repo, @data, @branchName) ->
    super
    @show()
    @setItems @parseData @data
    @focusFilterEditor()

  parseData: (files) ->
    trim_files_string = @data.replace /^\n+|\n+$/g, ""
    files_list = trim_files_string.split("\n")
    for line in files_list when /^([ MADRCU?!]{1})\s+(.*)/.test line
      if line != ""
        line = line.match /^([ MADRCU?!]{1})\s+(.*)/
        {type: line[1], path: line[2]}

  getFilterKey: -> 'path'

  getEmptyMessage: -> "Nothing to diff."

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
    fullPath = Path.join(@repo.getWorkingDirectory(), path)
    branchName = @branchName
    promise = atom.workspace.open fullPath,
      split: "left"
      activatePane: false
      activateItem: true
      searchAllPanes: false
    promise.then (editor) ->
      RevisionView.showRevision(editor, branchName, {type: type})
