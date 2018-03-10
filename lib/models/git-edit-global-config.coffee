git = require '../git'
notifier = require '../notifier'
{parse} = require 'url'

path = (line) ->
  {path} = parse line.replace /\t[.A-z]+$/,''
  decodeURI path

module.exports = ->
  git.cmd(['config', '--global', '-l', '--name-only', '--show-origin'])
  .then (lines) ->
    firstLine = lines.split('\n')[0]
    atom.workspace.open path firstLine
  .catch (err) ->
    notifier.addInfo err
