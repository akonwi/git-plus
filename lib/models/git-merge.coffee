{$, EditorView, View} = require 'atom'

git = require '../git'
StatusView = require '../views/status-view'
MergeListView = require '../views/merge-list-view'

module.exports.gitMerge = ->
  git.cmd
    args: ['branch'],
    stdout: (data) ->
      new MergeListView(data)

# class InputView extends View
#   @content: ->
#     @div class: 'overlay from-top', =>
#       @subview 'mergeEditor', new EditorView(mini: true, placeholderText: 'Branch name')
#
#   initialize: ->
#     @currentPane = atom.workspace.getActivePane()
#     atom.workspaceView.append this
#     @branchEditor.focus()
#     @on 'core:cancel', => @detach()
#     @branchEditor.on 'core:confirm', =>
#       text = $(this).text().split(' ')
#       name = if text.length is 2 then text[1] else text[0]
#       @mergeBranch name
#       @detach()
#
#   mergeBranch: (name) ->
#     git.cmd
#       args: ['merge', name],
#       stdout: (data) =>
#         new StatusView(type: 'success', message: data.toString())
#         atom.project.getRepo()?.refreshStatus()
#         @currentPane.activate()
#
# module.exports.newBranch = ->
#   new InputView()
