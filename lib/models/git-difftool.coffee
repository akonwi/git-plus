git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'
fs = require 'fs-plus'

module.exports = (repo, {file}={}) ->
  file ?= repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  isFolder = fs.isDirectorySync file

  if not file
    return notifier.addInfo "No open file. Select 'Diff All'."

  # We parse the output of git diff-index to handle the case of a staged file
  # when git-plus.includeStagedDiff is set to false.
  unless tool = git.getConfig(repo, 'diff.tool')
    notifier.addInfo "You don't have a difftool configured."
  else
    git.cmd(['diff-index', 'HEAD', '-z'], cwd: repo.getWorkingDirectory())
    .then (data) ->
      diffIndex = data.split('\0')
      includeStagedDiff = atom.config.get 'git-plus.includeStagedDiff'

      if isFolder
        args = ['difftool', '-d', '--no-prompt']
        args.push 'HEAD' if includeStagedDiff
        args.push file
        git.cmd(args, cwd: repo.getWorkingDirectory())
        .catch (msg) -> OutputViewManager.create().setContent(msg).finish()
        return

      diffsForCurrentFile = diffIndex.map (line, i) ->
        if i % 2 is 0
          staged = not /^0{40}$/.test(diffIndex[i].split(' ')[3]);
          path = diffIndex[i+1]
          true if path is file and (!staged or includeStagedDiff)
        else
          undefined

      if diffsForCurrentFile.filter((diff) -> diff?)[0]?
        args = ['difftool', '--no-prompt']
        args.push 'HEAD' if includeStagedDiff
        args.push file
        git.cmd(args, cwd: repo.getWorkingDirectory())
        .catch (msg) -> OutputViewManager.create().setContent(msg).finish()
      else
        notifier.addInfo 'Nothing to show.'
