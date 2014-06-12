{$, BufferedProcess, EditorView, View} = require 'atom'
StatusView = require './views/status-view'

# Public: Execute a git command.
#
# args     - The {Array} containing the arguments to pass.
# c_stdout - The {Function} to pass the stdout to.
# c_exit   - The {Function} to pass the exit code to.
#
# Returns: `undefined`
gitCmd = ({args, options, stdout, stderr, exit}={}) ->
  command = getGitPath()
  options ?= {}
  options.cwd ?= dir()
  stderr ?= (data) -> new StatusView(type: 'alert', message: data.toString())

  new BufferedProcess
    command: command
    args: args
    options: options
    stdout: stdout
    stderr: stderr
    exit: exit

gitStagedFiles = (stdout) ->
  gitCmd(
    args: ['diff-index', '--cached', 'HEAD', '--name-status', '-z']
    stdout: (data) -> stdout _prettify(data)
  )

gitUnstagedFiles = (stdout, showUntracked=false) ->
  gitCmd(
    args: ['diff-files', '--name-status', '-z']
    stdout: (data) ->
      if showUntracked
        gitUntrackedFiles(c_stdout, _prettify(data))
      else
        c_stdout _prettify(data)
  )

gitUntrackedFiles = (stdout, dataUnstaged=[]) ->
  gitCmd(
    args: ['ls-files', '-o', '--exclude-standard','-z']
    stdout: (data) -> stdout dataUnstaged.concat(_prettifyUntracked(data))
  )

gitDiff = (stdout, path) ->
  gitCmd(
    args: ['diff', '-p', path]
    stdout: (data) -> stdout _prettifyDiff(data)
  )

gitRefreshIndex = ->
  gitCmd(
    args: ['add', '--refresh', '.']
  )

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

module.exports.cmd = gitCmd
module.exports.stagedFiles = gitStagedFiles
module.exports.unstagedFiles = gitUnstagedFiles
module.exports.diff = gitDiff
module.exports.refresh = gitRefreshIndex
