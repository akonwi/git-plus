{exec} = require 'child_process'
{parse} = require 'url'

module.exports = ->

  open = (err, stdout) ->
    atom.workspace.open path stdout.split('\n')[0]

  path = (line) ->
    {path} = parse line.replace /\t[.A-z]+$/,''
    decodeURI path

  #git config --global --edit
  exec 'git config --global -l --name-only --show-origin', open #(err, stdout) ->
    #throw err if err?
    # {path} = parse stdout.toString().split('\n')[0].replace /\t.+/,''
    #atom.workspace.open decodeURI path
