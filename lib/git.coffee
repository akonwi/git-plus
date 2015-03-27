{BufferedProcess, GitRepository} = require 'atom'
StatusView = require './views/status-view'

# Public: Execute a git command.
#
# options - An {Object} with the following keys:
#   :args    - The {Array} containing the arguments to pass.
#   :options - The {Object} with options to pass.
#     :cwd  - Current working directory as {String}.
#   :stdout  - The {Function} to pass the stdout to.
#   :exit    - The {Function} to pass the exit code to.
#
# Returns nothing.
gitCmd = ({args, options, stdout, stderr, exit}={}) ->
  command = _getGitPath()
  options ?= {}
  options.cwd ?= dir()
  stderr ?= (data) -> new StatusView(type: 'error', message: data.toString())

  if stdout? and not exit?
    c_stdout = stdout
    stdout = (data) ->
      @save ?= ''
      @save += data
    exit = (exit) ->
      c_stdout @save ?= ''
      @save = null

  try
    new BufferedProcess
      command: command
      args: args
      options: options
      stdout: stdout
      stderr: stderr
      exit: exit
  catch error
    new StatusView(type: 'error', message: 'Git Plus is unable to locate git command. Please ensure process.env.PATH can access git.')

gitStatus = (stdout) ->
  gitCmd
    args: ['status', '--porcelain', '-z']
    stdout: (data) -> stdout(if data.length > 2 then data.split('\0') else [])

gitStagedFiles = (stdout) ->
  files = []
  gitCmd
    args: ['diff-index', '--cached', 'HEAD', '--name-status', '-z']
    stdout: (data) ->
      files = _prettify(data)
    stderr: (data) ->
      # edge case of no HEAD at initial commit
      if data.toString().contains "ambiguous argument 'HEAD'"
        files = [1]
      else
        new StatusView(type: 'error', message: data.toString())
        files = []
    exit: (code) -> stdout(files)

gitUnstagedFiles = (stdout, showUntracked=false) ->
  gitCmd
    args: ['diff-files', '--name-status', '-z']
    stdout: (data) ->
      if showUntracked
        gitUntrackedFiles(stdout, _prettify(data))
      else
        stdout _prettify(data)

gitUntrackedFiles = (stdout, dataUnstaged=[]) ->
  gitCmd
    args: ['ls-files', '-o', '--exclude-standard','-z']
    stdout: (data) ->
      stdout dataUnstaged.concat(_prettifyUntracked(data))

gitDiff = (stdout, path) ->
  gitCmd
    args: ['diff', '-p', '-U1', path]
    stdout: (data) -> stdout _prettifyDiff(data)

gitRefreshIndex = ->
  gitCmd
    args: ['add', '--refresh', '--', '.']
    stderr: (data) -> # don't really need to flash an error

gitAdd = ({file, stdout, stderr, exit}={}) ->
  exit ?= (code) ->
    if code is 0
      new StatusView(type: 'success', message: "Added #{file ? 'all files'}")
  gitCmd
    args: ['add', '--all', file ? '.'],
    stdout: stdout if stdout?
    stderr: stderr if stderr?
    exit: exit

gitMerge = ({branchName, stdout, stderr, exit}={}) ->
  exit ?= (code) ->
    if code is 0
      new StatusView(type: 'success', message: 'Git merged branch #{brachName} successfully')
  gitCmd
    args: ['merge', branchName],
    stdout: stdout if stdout?
    stderr: stderr if stderr?
    exit: exit

gitResetHead = ->
  gitCmd
    args: ['reset', 'HEAD']
    stdout: (data) ->
      new StatusView(type: 'success', message: 'All changes unstaged')

_getGitPath = ->
  atom.config.get('git-plus.gitPath') ? 'git'

_prettify = (data) ->
  data = data.split('\0')[...-1]
  files = [] = for mode, i in data by 2
    {mode: mode, path: data[i+1]}

_prettifyUntracked = (data) ->
  return [] if not data?
  data = data.split('\0')[...-1]
  files = [] = for file in data
    {mode: '?', path: file}

_prettifyDiff = (data) ->
  data = data.split(/^@@(?=[ \-\+\,0-9]*@@)/gm)
  data[1..data.length] = ('@@' + line for line in data[1..])
  data

# Returns the working directory for a git repo.
# Will search for submodule first if currently
#   in one or the project root
#
# @param andSubmodules boolean determining whether to account for submodules
dir = (andSubmodules=true) ->
  if andSubmodules
    if submodule = getSubmodule()
      return submodule.getWorkingDirectory()
  return getRepo()?.getWorkingDirectory() ? atom.project.getPath()

# returns filepath relativized for either a submodule or repository
#   otherwise just a full path
relativize = (path) ->
  getSubmodule(path)?.relativize(path) ? atom.project.getRepositories()[0]?.relativize(path) ? path

# returns submodule for given file or undefined
getSubmodule = (path) ->
  path ?= atom.workspace.getActiveEditor()?.getPath()
  atom.project.getRepositories()[0]?.repo.submoduleForPath(path)

# Public: Get the repository of the current file or project if no current file
# Returns a {GitRepository}-like object or null if not found.
getRepo = ->
  repo = GitRepository.open(atom.workspace.getActiveEditor()?.getPath(), refreshOnWindowFocus: false)
  if repo isnt null
    data = {
      references: repo.getReferences()
      shortHead: repo.getShortHead()
      workingDirectory: repo.getWorkingDirectory()
    }
    repo.destroy()
    return {
      getReferences: -> data.references
      getShortHead: -> data.shortHead
      getWorkingDirectory: -> data.workingDirectory
    }
  else
    return atom.project.getRepositories()[0]

module.exports.cmd = gitCmd
module.exports.stagedFiles = gitStagedFiles
module.exports.unstagedFiles = gitUnstagedFiles
module.exports.diff = gitDiff
module.exports.refresh = gitRefreshIndex
module.exports.status = gitStatus
module.exports.reset = gitResetHead
module.exports.add = gitAdd
module.exports.dir = dir
module.exports.relativize = relativize
module.exports.getSubmodule = getSubmodule
module.exports.getRepo = getRepo
