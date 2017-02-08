_ = require 'underscore-plus'
path = require 'path'
fs = require 'fs'

{CompositeDisposable, BufferedProcess} = require "atom"
{$} = require "atom-space-pen-views"

SplitDiff = require 'split-diff'


module.exports =
class GitRevisionView

  @showRevision: (editor, gitRevision, options={}) ->
    options = _.defaults options,
      diff: false

    SplitDiff.disable(false)

    file = editor.getPath()

    args = ["show", "#{gitRevision}:./#{path.basename(file)}"]
    git.cmd(args, cwd: path.dirname(file))
    .then (data) ->
      @_showRevision(file, editor, gitRevision, data, options)
    .catch (code) ->
      atom.notifications.addError "Could not retrieve revision for #{path.basename(file)} (#{code})"

  @_getInitialLineNumber: (editor) ->
    editorEle = atom.views.getView editor
    lineNumber = 0
    if editor? && editor != ''
      lineNumber = editorEle.getLastVisibleScreenRow()
      return lineNumber - 5


  @_showRevision: (file, editor, gitRevision, fileContents, options={}) ->
    outputDir = "#{atom.getConfigDirPath()}/git-plus"
    fs.mkdir outputDir if not fs.existsSync outputDir
    outputFilePath = "#{outputDir}/#{gitRevision}#{path.basename(file)}"
    outputFilePath += ".diff" if options.diff
    tempContent = "Loading..." + editor.buffer?.lineEndingForRow(0)
    fs.writeFile outputFilePath, tempContent, (error) =>
      if not error
        promise = atom.workspace.open file,
          split: "left"
          activatePane: false
          activateItem: true
          searchAllPanes: false
        promise.then (editor) =>
          promise = atom.workspace.open outputFilePath,
            split: "right"
            activatePane: false
            activateItem: true
            searchAllPanes: false
          promise.then (newTextEditor) =>
            @_updateNewTextEditor(newTextEditor, editor, gitRevision, fileContents)


  @_updateNewTextEditor: (newTextEditor, editor, gitRevision, fileContents) ->
    _.delay =>
      lineEnding = editor.buffer?.lineEndingForRow(0) || "\n"
      fileContents = fileContents.replace(/(\r\n|\n)/g, lineEnding)
      newTextEditor.buffer.setPreferredLineEnding(lineEnding)
      newTextEditor.setText(fileContents)
      newTextEditor.buffer.cachedDiskContents = fileContents
      @_splitDiff(editor, newTextEditor)
      @_syncScroll(editor, newTextEditor)
      @_affixTabTitle newTextEditor, gitRevision
    , 300


  @_affixTabTitle: (newTextEditor, gitRevision) ->
    $el = $(atom.views.getView(newTextEditor))
    $tabTitle = $el.parents('atom-pane').find('li.tab.active .title')
    titleText = $tabTitle.text()
    if titleText.indexOf('@') >= 0
      titleText = titleText.replace(/\@.*/, "@#{gitRevision}")
    else
      titleText += " @#{gitRevision}"
    $tabTitle.text(titleText)


  @_splitDiff: (editor, newTextEditor) ->
    editors =
      editor1: newTextEditor    # the older revision
      editor2: editor           # current rev
    SplitDiff._setConfig 'rightEditorColor', 'green'
    SplitDiff._setConfig 'leftEditorColor', 'red'
    SplitDiff._setConfig 'diffWords', true
    SplitDiff._setConfig 'ignoreWhitespace', true
    SplitDiff._setConfig 'syncHorizontalScroll', true
    SplitDiff.editorSubscriptions = new CompositeDisposable()
    SplitDiff.editorSubscriptions.add editors.editor1.onDidStopChanging =>
      SplitDiff.updateDiff(editors) if editors?
    SplitDiff.editorSubscriptions.add editors.editor2.onDidStopChanging =>
      SplitDiff.updateDiff(editors) if editors?
    SplitDiff.editorSubscriptions.add editors.editor1.onDidDestroy =>
      editors = null;
      SplitDiff.disable(false)
    SplitDiff.editorSubscriptions.add editors.editor2.onDidDestroy =>
      editors = null;
      SplitDiff.disable(false)
    SplitDiff.updateDiff editors


  @_syncScroll: (editor, newTextEditor) ->
    _.delay =>
      return if newTextEditor.isDestroyed()
      newTextEditor.scrollToBufferPosition({row: @_getInitialLineNumber(editor), column: 0})
    , 50
