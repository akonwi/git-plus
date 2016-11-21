Os = require 'os'
{BufferedProcess} = require 'atom'

RepoListView = require './views/repo-list-view'
notifier = require './notifier'

gitUntrackedFiles = (repo, dataUnstaged=[]) ->
  args = ['ls-files', '-o', '--exclude-standard']
  git.cmd(args, cwd: repo.getWorkingDirectory())
  .then (data) ->
    dataUnstaged.concat(_prettifyUntracked(data))

_prettify = (data) ->
  return [] if data is ''
  data = data.split(/\0/)[...-1]
  [] = for mode, i in data by 2
    {mode, path: data[i+1] }
  # data = data.split(/\n/)
  # data.filter((file) -> file isnt '').map (file) ->
  #   {mode: file[0], path: file.substring(1).trim()}

_prettifyUntracked = (data) ->
  return [] if data is ''
  data = data.split(/\n/).filter (d) -> d isnt ''
  data.map (file) -> {mode: '?', path: file}

_prettifyDiff = (data) ->
  data = data.split(/^@@(?=[ \-\+\,0-9]*@@)/gm)
  data[1..data.length] = ('@@' + line for line in data[1..])
  data

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

module.exports = git =
  cmd: (args, options={ env: process.env}, {color}={}) ->
    new Promise (resolve, reject) ->
      output = ''
      args = ['-c', 'color.ui=always'].concat(args) if color
      process = new BufferedProcess
        command: atom.config.get('git-plus.gitPath') ? 'git'
        args: args
        options: options
        stdout: (data) -> output += data.toString()
        stderr: (data) ->
          output += data.toString()
        exit: (code) ->
          if code is 0
            resolve output
          else
            reject output
      process.onWillThrowError (errorObject) ->
        notifier.addError 'Git Plus is unable to locate the git command. Please ensure process.env.PATH can access git.'
        reject "Couldn't find git"

  getConfig: (repo, setting) -> repo.getConfigValue setting, repo.getWorkingDirectory()

  reset: (repo) ->
    git.cmd(['reset', 'HEAD'], cwd: repo.getWorkingDirectory()).then () -> notifier.addSuccess 'All changes unstaged'

  status: (repo) ->
    git.cmd(['status', '--porcelain', '-z'], cwd: repo.getWorkingDirectory())
    .then (data) -> if data.length > 2 then data.split('\0')[...-1] else []

  refresh: (repo) ->
    if repo
      repo.refreshStatus?()
      repo.refreshIndex?()
    else
      atom.project.getRepositories().forEach (repo) -> repo.refreshStatus() if repo?

  relativize: (path) ->
    git.getSubmodule(path)?.relativize(path) ? atom.project.getRepositories()[0]?.relativize(path) ? path

  diff: (repo, path) ->
    git.cmd(['diff', '-p', '-U1', path], cwd: repo.getWorkingDirectory())
    .then (data) -> _prettifyDiff(data)

  stagedFiles: (repo, stdout) ->
    args = ['diff-index', '--cached', 'HEAD', '--name-status', '-z']
    git.cmd(args, cwd: repo.getWorkingDirectory())
    .then (data) ->
      _prettify data
    .catch (error) ->
      if error.includes "ambiguous argument 'HEAD'"
        Promise.resolve [1]
      else
        notifier.addError error
        Promise.resolve []

  unstagedFiles: (repo, {showUntracked}={}) ->
    args = ['diff-files', '--name-status', '-z']
    git.cmd(args, cwd: repo.getWorkingDirectory())
    .then (data) ->
      if showUntracked
        gitUntrackedFiles(repo, _prettify(data))
      else
        _prettify(data)

  add: (repo, {file, update}={}) ->
    args = ['add']
    if update then args.push '--update' else args.push '--all'
    args.push(if file then file else '.')
    git.cmd(args, cwd: repo.getWorkingDirectory())
    .then (output) ->
      if output isnt false
        notifier.addSuccess "Added #{file ? 'all files'}"
    .catch (msg) -> notifier.addError msg

  getRepo: ->
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

  getSubmodule: (path) ->
    path ?= atom.workspace.getActiveTextEditor()?.getPath()
    atom.project.getRepositories().filter((r) ->
      r?.repo?.submoduleForPath path
    )[0]?.repo?.submoduleForPath path

  dir: (andSubmodules=true) ->
    new Promise (resolve, reject) =>
      if andSubmodules and submodule = git.getSubmodule()
        resolve(submodule.getWorkingDirectory())
      else
        git.getRepo().then (repo) -> resolve(repo.getWorkingDirectory())
