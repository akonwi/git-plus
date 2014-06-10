{$, BufferedProcess, EditorView, View} = require 'atom'
StatusView = require './views/status-view'

# Public: Execute a git command.
#
# args     - The {Array} containing the arguments to pass.
# c_stdout - The {Function} to pass the stdout to.
# c_exit   - The {Function} to pass the exit code to.
#
# Returns: `undefined`
gitCmd = (args, c_stdout, c_exit) ->
  new BufferedProcess
    command: 'git'
    args: args
    options:
      cwd: dir()
    stdout: c_stdout
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
    exit: c_exit

gitStagedFiles = (c_stdout) ->
  new BufferedProcess
    command: 'git'
    args: ['diff-index', '--cached', 'HEAD', '--name-status', '-z']
    options:
      cwd: dir()
    stdout: (data) -> c_stdout _prettify(data)
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())

gitUnstagedFiles = (c_stdout, showUntracked=false) ->
  new BufferedProcess
    command: 'git'
    args: ['diff-files', '--name-status', '-z']
    options:
      cwd: dir()
    stdout: (data) ->
      if showUntracked
        gitUntrackedFiles(c_stdout, _prettify(data))
      else
        c_stdout _prettify(data)
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())

gitUntrackedFiles = (c_stdout, dataUnstaged=[]) ->
  new BufferedProcess
    command: 'git'
    args: ['ls-files', '-o', '--exclude-standard','-z']
    options:
      cwd: dir()
    stdout: (data) -> c_stdout dataUnstaged.concat(_prettifyUntracked(data))
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())

gitDiff = (c_stdout, path) ->
  new BufferedProcess
    command: 'git'
    args: ['diff', '-p', path]
    options:
      cwd: dir()
    stdout: (data) -> c_stdout _prettifyDiff(data)
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())

_prettify = (data) ->
  data = data.split('\0')[...-1]
  files = [] = for mode, i in data by 2
    {mode: mode, path: data[i+1]}

_prettifyUntracked = (data) ->
  data = data.split('\0')[...-1]
  files = [] = for file in data
    {mode: '?', path: file}

_prettifyDiff = (data) ->
  data = data.split(/^@@(?=[ \-\+\,0-9]*@@)/gm)
  data[1..data.length] = ('@@' + line for line in data[1..])
  data

# Public: Return the current WorkingDirectory
#
# Returns the current WorkingDirectory as {String}.
dir = ->
  if atom.project.getRepo()?
    atom.project.getRepo().getWorkingDirectory()
  else
    atom.project.getPath()

module.exports = gitCmd
module.exports.stagedFiles = gitStagedFiles
module.exports.unstagedFiles = gitUnstagedFiles
module.exports.diff = gitDiff
