{$$, SelectListView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
git = require '../git'
notifier = require '../notifier'
BranchListView = require './branch-list-view'
GitDiff = require '../models/git-diff'
Path = require 'path'
RevisionView = require './git-revision-view'

_cwd  = ""
_currentBranch = ""
_branchName = ""

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
    _cwd = @repo.getWorkingDirectory()
    _currentBranch = @repo.branch
    _branchName = @branchName
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
    console.log('git diff file path', path)
    fullPath = Path.join(_cwd, path)
    if type == "M"
      args = ['diff', '--raw', _currentBranch, _branchName, fullPath]
      _cwd = Path.dirname(fullPath)
      console.log('git diff file', args, _cwd)
      git.cmd(args, cwd: _cwd)
      .then (data) ->
        if !!data
          metaData = data.split(/\s/g)
          console.log('metaData', metaData)
          revHash = metaData[3].replace(/\.+/, "")
          file = metaData[5]
          promise = atom.workspace.open file,
            split: "left"
            activatePane: false
            activateItem: true
            searchAllPanes: false
          promise.then (editor) ->
            RevisionView.showRevision(editor, revHash, {cwd:_cwd})
