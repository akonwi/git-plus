{BufferedProcess} = require 'atom'
OutputView = require './output-view'

gitPull = ->
  dir = atom.project.getRepo()?.getWorkingDirectory() ? atom.project.getPath()
  view = new OutputView()
  new BufferedProcess({
    command: 'git'
    args: ['pull']
    options:
      cwd: dir
    stdout: (data) ->
      view.addLine(data.toString())
    stderr: (data) ->
      view.addLine(data.toString())
    exit: (code) ->
      view.finish()
  })

module.exports = gitPull
