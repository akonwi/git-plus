{$$, SelectListView} = require 'atom-space-pen-views'
fs = require 'fs-plus'
git = require '../git'
notifier = require '../notifier'
BranchListView = require './branch-list-view'
GitDiff = require '../models/git-diff'

module.exports =
class DiffBranchFilesListView extends BranchListView
  initialize: (@repo, @data) ->
    super
    @show()
    @setItems @parseData @data
    @focusFilterEditor()

  parseData: (files) ->
    console.log("diff-branch-files-view:files", files)
    console.log("diff-branch-files-view:data", @data)
    trim_files_string = @data.replace /^\n+|\n+$/g, ""
    files_list = trim_files_string.split("\n")
    console.log("diff-branch-files-view:files_list", files_list)
    for line in files_list when /^([ MADRCU?!]{1})\s+(.*)/.test line
      if line != ""
        line = line.match /^([ MADRCU?!]{1})\s+(.*)/
        console.log('line:', line)
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
    console.log("confirmed", {type, path})
    @cancel()
    if type is '??'
      git.add @repo, file: path
    else
      fullPath = Path.join(@repo.getWorkingDirectory(), path)

      fs.stat fullPath, (err, stat) =>
        if err
          notifier.addError(err.message)
        else
          GitDiff(@repo, file: path)
          # GitDiff(repo, diffStat: data, file: file)
