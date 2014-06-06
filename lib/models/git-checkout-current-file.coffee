{BufferedProcess} = require 'atom'
StatusView = require './status-view'
Path = require 'path'

gitCheckoutCurrentFile = ()->
  dir = atom.project.getRepo().getWorkingDirectory()
  currentFile = atom.workspace.getActiveEditor()?.getPath()
  new BufferedProcess({
    command: 'git'
    args: ['checkout', currentFile]
    options:
      cwd: dir
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
    exit: (exitCode) ->
      if exitCode != 0
        new StatusView(type: 'alert', message: "Checkout failed with exit code #{exitCode}")
  })


module.exports = gitCheckoutCurrentFile
