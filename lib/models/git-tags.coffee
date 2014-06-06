{BufferedProcess} = require 'atom'
TagListView = require '../views/tag-list-view'
StatusView = require '../views/status-view'

dir = ->
  atom.project.getRepo().getWorkingDirectory()

gitTags = ->
  @TagListView = null

  new BufferedProcess
    command: 'git'
    args: ['tag', '-ln']
    options:
      cwd: dir()
    stdout: (data) ->
      @TagListView = new TagListView(data)
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
    exit: (code, data) ->
      new TagListView('') if not @TagListView?

module.exports = gitTags
