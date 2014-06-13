{BufferedProcess} = require 'atom'
OutputView = require '../views/output-view'
git = require '../git'

gitPull = ->
  view = new OutputView()
  git.cmd
    args: ['pull']
    stdout: (data) -> view.addLine(data.toString())
    stderr: (data) -> view.addLine(data.toString())
    exit: (code) -> view.finish()

module.exports = gitPull
