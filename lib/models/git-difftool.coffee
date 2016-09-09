Path = require 'flavored-path'
git = require '../git'
notifier = require '../notifier'
OutputViewManager = require '../output-view-manager'
fs = require 'fs-plus'

module.exports = (repo, {file}={}) ->

  if atom.packages.isPackageLoaded('tree-view')
    treeView = atom.packages.getLoadedPackage('tree-view')
    treeView = require(treeView.mainModulePath)
    packageObj = treeView.serialize()
  else if atom.packages.isPackageLoaded('sublime-tabs')
    sublimeTabs = atom.packages.getLoadedPackage('sublime-tabs')
    sublimeTabs = require(sublimeTabs.mainModulePath)
    packageObj = sublimeTabs.serialize()
  else
    console.warn("Git-plus: no tree-view or sublime-tabs package loaded")

  isFolder = false
  if not file
    if packageObj?.selectedPath
      isFolder = fs.isDirectorySync packageObj.selectedPath
      file ?= repo.relativize(packageObj.selectedPath)
  else
    isFolder = fs.isDirectorySync file

  file ?= repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  if not file
    return notifier.addInfo "No open file. Select 'Diff All'."

  # We parse the output of git diff-index to handle the case of a staged file
  # when git-plus.includeStagedDiff is set to false.
  git.getConfig('diff.tool', repo.getWorkingDirectory()).then (tool) ->
    unless tool
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
          .catch (msg) -> OutputViewManager.create().addLine(msg).finish()
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
          .catch (msg) -> OutputViewManager.create().addLine(msg).finish()
        else
          notifier.addInfo 'Nothing to show.'
