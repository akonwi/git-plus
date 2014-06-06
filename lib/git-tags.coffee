{BufferedProcess} = require 'atom'
TagListView = require './tag-list-view'
StatusView = require './status-view'

dir = ->
  atom.project.getRepo().getWorkingDirectory()

gitTags = ->
  args = ['tag', '-ln']

  new BufferedProcess
    command: 'git'
    args: args
    options:
      cwd: dir()
    stdout: (data) ->
      new TagListView(data)
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())

module.exports = gitTags
