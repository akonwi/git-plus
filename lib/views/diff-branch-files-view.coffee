{$$, SelectListView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
git = require '../git'
notifier = require '../notifier'
StatusListView = require './status-list-view'
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
class DiffBranchFilesListView extends StatusListView
  initialize: (@repo, @data, @branchName, selectedFilePath) ->
    super
    @setItems @parseData @data
    if @items.length is 0
      notifier.addInfo("The branch '#{@branchName}' has no differences")
      return @cancel()
    @confirmed(path: @repo.relativize(selectedFilePath)) if selectedFilePath
    @show()
    @focusFilterEditor()

  parseData: (files) ->
    trim_files_string = @data.replace /^\n+|\n+$/g, ""
    files_list = trim_files_string.split("\n")
    for line in files_list when /^([ MADRCU?!]{1})\s+(.*)/.test line
      if line != ""
        line = line.match /^([ MADRCU?!]{1})\s+(.*)/
        {type: line[1], path: line[2]}

  confirmed: ({type, path}) ->
    @cancel()
    fullPath = Path.join(@repo.getWorkingDirectory(), path)
    promise = atom.workspace.open fullPath,
      split: "left"
      activatePane: false
      activateItem: true
      searchAllPanes: false
    promise.then (editor) =>
      RevisionView.showRevision(@repo, editor, @branchName)
