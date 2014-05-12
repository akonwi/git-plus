{BufferedProcess} = require 'atom'
OutputView = require './output-view'

gitPush = ->
  dir = atom.project.getRepo().getWorkingDirectory()
  view = new OutputView()
  new BufferedProcess({
    command: 'git'
    args: ['push']
    options:
      cwd: dir
    stdout: (data) ->
      view.addLine(data.toString())
    stderr: (data) ->
      view.addLine(data.toString())
    exit: (code) ->
      view.finish()
  })

module.exports = gitPush
