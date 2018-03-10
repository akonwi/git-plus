{join} = require 'path'
fs = null
git = require '../git'
notifier = require '../notifier'

module.exports = ->
  git.cmd(['config', '--global', 'core.attributesfile'])
  .then (gitignore) ->
    fs ?= require 'fs-plus'
    atom.workspace.open gitignore.replace /^~/, fs.getHomeDirectory()
  .catch (err) ->
    if err
      notifier.addInfo err
    else path =
        if XDG = process.env.XDG_CONFIG_HOME
          [ XDG, 'git']
        else [ process.env.HOME, '.config', 'git']
      gitignore = join(path..., 'attributes')
      atom.workspace.open gitignore
