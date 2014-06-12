fs = require 'fs-plus'
{$, $$, EditorView} = require 'atom'

git = require '../git'
OutputView = require './output-view'
StatusView = require './status-view'
SelectListMultipleView = require './select-list-multiple-view'

module.exports =
class SelectStageHunks extends SelectListMultipleView

  initialize: (data) ->
    super
    @patch_header = data[0]
    @addClass('overlay from-top')

    @setItems @_generateObjects(data[1..])
    atom.workspaceView.append(this)
    @focusFilterEditor()

  getFilterKey: ->
    'pos'

  addButtons: ->
    viewButton = $$ ->
      @div class: 'buttons', =>
        @span class: 'pull-left', =>
          @button class: 'btn btn-error inline-block-tight btn-cancel-button', 'Cancel'
        @span class: 'pull-right', =>
          @button class: 'btn btn-success inline-block-tight btn-stage-button', 'Stage'
    viewButton.appendTo(this)

    @on 'click', 'button', ({target}) =>
      @complete() if $(target).hasClass('btn-stage-button')
      @cancel() if $(target).hasClass('btn-cancel-button')

  viewForItem: (item) ->
    viewItem = $$ ->
      @li =>
        @div class: 'inline-block highlight', item.pos
        @div class: 'text-warning gp-item-diff', style: 'white-space: pre-wrap; font-family: monospace', item.diff

  completed: (items) ->
    @cancel()
    return if items.length<1

    patch_full = @patch_header
    patch_full += patch for {patch} in items

    patchPath = atom.project.getRepo().getWorkingDirectory() + '/.git/GITPLUS_PATCH'
    fs.writeFileSync patchPath, patch_full, flag: 'w+'

    git.cmd(
      args: ['apply', '--cached', '--', patchPath],
      stdout: (data) ->
        new StatusView(type: 'success', message: data)
        fs.writeFileSync patchPath, '', flag: 'w+'
    )

  _generateObjects: (data) ->
    for hunk in data when hunk isnt ''
      hunkSplit = hunk.match /(@@[ \-\+\,0-9]*@@.*)\n([\s\S]*)/
      {
        pos: hunkSplit[1]
        diff: hunkSplit[2]
        patch: hunk
      }
