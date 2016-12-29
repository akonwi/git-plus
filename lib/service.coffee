git = require './git'
GitRun = require './models/git-run'

capitalize = (text) -> text.split(' ').map((word) -> word[0].toUpperCase() + word.substring(1)).join(' ')

customCommands = []

service = {}

if atom.config.get('git-plus.experimental.customCommands')
  service.getCustomCommands = -> customCommands
  service.getRepo = git.getRepo
  service.registerCommand = (element, name, fn) ->
    atom.commands.add element, name, fn
    displayName = capitalize(name.split(':')[1].replace(/-/g, ' '))
    customCommands.push [name, displayName, fn]
  service.run = GitRun

module.exports = Object.freeze service
