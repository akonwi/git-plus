{BufferedProcess} = require 'atom'
OutputView = require '../views/output-view'
git = require '../git'

gitPull = ->
  dir = atom.project.getRepo().getWorkingDirectory()
  view = new OutputView()
  git(
    args: ['pull']
    stdout: (data) -> view.addLine(data.toString())
    stderr: (data) -> view.addLine(data.toString())
    exit: (code) -> view.finish()
  )

module.exports = gitPull
