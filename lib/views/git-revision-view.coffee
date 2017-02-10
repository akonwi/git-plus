_ = require 'underscore-plus'
path = require 'path'
fs = require 'fs'
git = require '../git'

{CompositeDisposable, BufferedProcess} = require "atom"
{$} = require "atom-space-pen-views"

disposables = new CompositeDisposable
SplitDiff = null
SyncScroll = null

module.exports =
class GitRevisionView

  @showRevision: (editor, gitRevision, options={}) ->
    if not SplitDiff
      try
        SplitDiff = require atom.packages.resolvePackagePath('split-diff')
        SyncScroll = require atom.packages.resolvePackagePath('split-diff') + '/lib/sync-scroll'
        atom.themes.requireStylesheet(atom.packages.resolvePackagePath('split-diff') + '/styles/split-diff')
      catch error
        return atom.notifications.addInfo("Git Plus: Could not load 'split-diff' package to open diff view. Please install it `apm install split-diff`.")

    options = _.defaults options,
      diff: false

    SplitDiff.disable(false)

    file = editor.getPath()

    self = @
    args = ["show", "#{gitRevision}:./#{path.basename(file)}"]
    git.cmd(args, cwd: path.dirname(file))
    .then (data) ->
      self._showRevision(file, editor, gitRevision, data, options)
    .catch (code) ->
      atom.notifications.addError("Git Plus: Could not retrieve revision for #{path.basename(file)} (#{code})")

  @_getInitialLineNumber: (editor) ->
    editorEle = atom.views.getView editor
    lineNumber = 0
    if editor? && editor != ''
      lineNumber = editorEle.getLastVisibleScreenRow()
      return lineNumber - 5


  @_showRevision: (file, editor, gitRevision, fileContents, options={}) ->
    outputDir = "#{atom.getConfigDirPath()}/git-plus"
    fs.mkdir outputDir if not fs.existsSync outputDir
    gitRevision = path.basename(gitRevision)
    outputFilePath = "#{outputDir}/#{gitRevision}##{path.basename(file)}"
    outputFilePath += ".diff" if options.diff
    tempContent = "Loading..." + editor.buffer?.lineEndingForRow(0)
    fs.writeFile outputFilePath, tempContent, (error) =>
      if not error
        atom.workspace.open file,
          split: "left"
        .then (editor) =>
          atom.workspace.open outputFilePath,
            split: "right"
          .then (newTextEditor) =>
            @_updateNewTextEditor(newTextEditor, editor, gitRevision, fileContents)
            try
              disposables.add newTextEditor.onDidDestroy -> fs.unlink outputFilePath
            catch error
              return atom.notifications.addError "Could not remove file #{outputFilePath}"

  @_updateNewTextEditor: (newTextEditor, editor, gitRevision, fileContents) ->
    _.delay =>
      lineEnding = editor.buffer?.lineEndingForRow(0) || "\n"
      fileContents = fileContents.replace(/(\r\n|\n)/g, lineEnding)
      newTextEditor.buffer.setPreferredLineEnding(lineEnding)
      newTextEditor.setText(fileContents)
      newTextEditor.buffer.cachedDiskContents = fileContents
      @_splitDiff(editor, newTextEditor)
    , 300

  @_splitDiff: (editor, newTextEditor) ->
    editors =
      editor1: newTextEditor    # the older revision
      editor2: editor           # current rev
    SplitDiff._setConfig 'diffWords', true
    SplitDiff._setConfig 'ignoreWhitespace', true
    SplitDiff._setConfig 'syncHorizontalScroll', true
    SplitDiff.diffPanes()
    SplitDiff.updateDiff(editors)
    syncScroll = new SyncScroll(editors.editor1, editors.editor2, true)
    syncScroll.syncPositions()
