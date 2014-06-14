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
    return @completed @_generateObjects(data[1..]) if data.length is 2

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

  viewForItem: (item, matchedStr) ->
    viewItem = $$ ->
      @li =>
        @div class: 'inline-block highlight', =>
          if matchedStr? then @raw(matchedStr) else @span item.pos
        @div class: 'text-warning gp-item-diff', style: 'white-space: pre-wrap; font-family: monospace', item.diff

  completed: (items) ->
    @cancel()
    return if items.length<1

    patch_full = @patch_header
    patch_full += patch for {patch} in items

    patchPath = atom.project.getRepo().getWorkingDirectory() + '/.git/GITPLUS_PATCH'
    fs.writeFileSync patchPath, patch_full, flag: 'w+'

    git.cmd
      args: ['apply', '--cached', '--', patchPath],
      stdout: (data) ->
        data = if data? and data isnt '' then data else 'Hunk has been staged!'
        new StatusView(type: 'success', message: data)
        try fs.unlink patchPath

  _generateObjects: (data) ->
    for hunk in data when hunk isnt ''
      hunkSplit = hunk.match /(@@[ \-\+\,0-9]*@@.*)\n([\s\S]*)/
      {
        pos: hunkSplit[1]
        diff: hunkSplit[2]
        patch: hunk
      }
