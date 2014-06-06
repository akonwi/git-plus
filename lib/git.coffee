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


# Public: Return the current WorkingDirectory
#
# Returns the current WorkingDirectory as {String}.
dir = -> atom.project.getRepo().getWorkingDirectory()

module.exports = gitCmd
