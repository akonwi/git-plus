{BufferedProcess} = require 'atom'
RepoListView = require './views/repo-list-view'
notifier = require './notifier'

# Public: Execute a git command.
#
# args    - An {Array} containing the arguments for the command.
# options - An {Object} with the following keys:
#   :cwd  - Current working directory as {String}.
#   :options - The {Object} with options to pass.
#
# Returns a {Promise}.
gitCmd = (args, {cwd, options}={}) ->
  new Promise (resolve, reject) ->
    command = _getGitPath()
    options ?= {}
    options.cwd ?= cwd
    output = ''
    try
      new BufferedProcess
        command: command
        args: args
        options: options
        stdout: (data) -> output += data
        stderr: (data) -> reject data.toString()
        exit: (code) ->
          if code is 0 then resolve output else resolve false
    catch
      notifier.addError 'Git Plus is unable to locate the git command. Please ensure process.env.PATH can access git.'
      reject "Couldn't find git"

gitStatus = (repo, stdout) ->
  gitCmd
    args: ['status', '--porcelain', '-z']
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> stdout(if data.length > 2 then data.split('\0') else [])

gitStagedFiles = (repo, stdout) ->
  args = ['diff-index', '--cached', 'HEAD', '--name-status', '-z']
  gitCmd(args, cwd: repo.getWorkingDirectory())
  .then (data) -> _prettify data
  .catch (error) ->
    if error.includes "ambiguous argument 'HEAD'"
      Promise.resolve [1]
    else
      notifier.addError error
      Promise.resolve []

  # gitCmd
  #   args: ['diff-index', '--cached', 'HEAD', '--name-status', '-z']
  #   cwd: repo.getWorkingDirectory()
  #   stdout: (data) ->
  #     files = _prettify(data)
  #   stderr: (data) ->
  #     # edge case of no HEAD at initial commit
  #     if data.toString().includes "ambiguous argument 'HEAD'"
  #       files = [1]
  #     else
  #       notifier.addError data.toString()
  #       files = []
  #   exit: (code) -> stdout(files)

gitUnstagedFiles = (repo, {showUntracked}={}, stdout) ->
  gitCmd
    args: ['diff-files', '--name-status', '-z']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      if showUntracked
        gitUntrackedFiles(repo, _prettify(data), stdout)
      else
        stdout _prettify(data)

gitUntrackedFiles = (repo, dataUnstaged=[], stdout) ->
  gitCmd
    args: ['ls-files', '-o', '--exclude-standard','-z']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      stdout dataUnstaged.concat(_prettifyUntracked(data))

gitDiff = (repo, path, stdout) ->
  gitCmd
    args: ['diff', '-p', '-U1', path]
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> stdout _prettifyDiff(data)

gitRefresh = ->
  atom.project.getRepositories().forEach (r) -> r?.refreshStatus()
  gitCmd
    args: ['add', '--refresh', '--', '.']
    stderr: (data) -> # don't really need to flash an error

gitAdd = (repo, {file, update}={}) ->
  args = ['add']
  if update then args.push '--update' else args.push '--all'
  if file then args.push file else '.'
  gitCmd(args, cwd: repo.getWorkingDirectory())
  .then (output) ->
    if output isnt false
      notifier.addSuccess "Added #{file ? 'all files'}"
      true

gitResetHead = (repo) ->
  gitCmd
    args: ['reset', 'HEAD']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      notifier.addSuccess 'All changes unstaged'

_getGitPath = ->
  p = atom.config.get('git-plus.gitPath') ? 'git'
  console.log "Git-plus: Using git at", p
  return p

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
  new Promise (resolve, reject) ->
    if andSubmodules and submodule = getSubmodule()
      resolve(submodule.getWorkingDirectory())
    else
      getRepo().then (repo) -> resolve(repo.getWorkingDirectory())

# returns filepath relativized for either a submodule or repository
#   otherwise just a full path
relativize = (path) ->
  getSubmodule(path)?.relativize(path) ? atom.project.getRepositories()[0]?.relativize(path) ? path

# returns submodule for given file or undefined
getSubmodule = (path) ->
  path ?= atom.workspace.getActiveTextEditor()?.getPath()
  repo = atom.project.getRepositories().filter((r) ->
    r?.repo.submoduleForPath path
  )[0]?.repo?.submoduleForPath path

# Public: Get the repository of the current file or project if no current file
# Returns a {Promise} that resolves to a repository like object
getRepo = ->
  new Promise (resolve, reject) ->
    getRepoForCurrentFile().then (repo) -> resolve(repo)
    .catch (e) ->
      repos = atom.project.getRepositories().filter (r) -> r?
      if repos.length is 0
        reject("No repos found")
      else if repos.length > 1
        resolve(new RepoListView(repos).result)
      else
        resolve(repos[0])

getRepoForCurrentFile = ->
  new Promise (resolve, reject) ->
    project = atom.project
    path = atom.workspace.getActiveTextEditor()?.getPath()
    directory = project.getDirectories().filter((d) -> d.contains(path))[0]
    if directory?
      project.repositoryForDirectory(directory).then (repo) ->
        submodule = repo.repo.submoduleForPath(path)
        if submodule? then resolve(submodule) else resolve(repo)
      .catch (e) ->
        reject(e)
    else
      reject "no current file"

module.exports.cmd = gitCmd
module.exports.stagedFiles = gitStagedFiles
module.exports.unstagedFiles = gitUnstagedFiles
module.exports.diff = gitDiff
module.exports.refresh = gitRefresh
module.exports.status = gitStatus
module.exports.reset = gitResetHead
module.exports.add = gitAdd
module.exports.dir = dir
module.exports.relativize = relativize
module.exports.getSubmodule = getSubmodule
module.exports.getRepo = getRepo
