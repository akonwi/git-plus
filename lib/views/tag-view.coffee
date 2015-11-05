{$$, SelectListView} = require 'atom-space-pen-views'

git = require '../git'
GitShow = require '../models/git-show'
notifier = require '../notifier'
RemoteListView = require '../views/remote-list-view'

module.exports =
class TagView extends SelectListView
  initialize: (@repo, @tag) ->
    super
    @show()
    @parseData()

  parseData: ->
    items = []
    items.push {tag: @tag, cmd: 'Show', description: 'git show'}
    items.push {tag: @tag, cmd: 'Push', description: 'git push [remote]'}
    items.push {tag: @tag, cmd: 'Checkout', description: 'git checkout'}
    items.push {tag: @tag, cmd: 'Verify', description: 'git tag --verify'}
    items.push {tag: @tag, cmd: 'Delete', description: 'git tag --delete'}

    @setItems items
    @focusFilterEditor()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @storeFocusedElement()

  cancelled: -> @hide()

  hide: -> @panel?.destroy()

  viewForItem: ({tag, cmd, description}) ->
    $$ ->
      @li =>
        @div class: 'text-highlight', cmd
        @div class: 'text-warning', "#{description} #{tag}"

  getFilterKey: -> 'cmd'

  confirmed: ({tag, cmd}) ->
    @cancel()
    switch cmd
      when 'Show'
        GitShow(@repo, tag)
      when 'Push'
        git.cmd(['remote'], cwd: @repo.getWorkingDirectory())
        .then (data) => new RemoteListView(@repo, data, mode: 'push', tag: @tag)
      when 'Checkout'
        args = ['checkout', tag]
      when 'Verify'
        args = ['tag', '--verify', tag]
      when 'Delete'
        args = ['tag', '--delete', tag]

    if args?
      git.cmd(args, cwd: @repo.getWorkingDirectory())
      .then (data) -> notifier.addSuccess data
      .catch (msg) -> notifier.addWarning msg
