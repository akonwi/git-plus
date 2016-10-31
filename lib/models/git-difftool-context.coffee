notifier = require '../notifier'
GitDiffTool = require './git-difftool'

module.exports = (repo, contextCommandMap) ->
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

  if packageObj?.selectedPath
    contextCommandMap 'difftool', repo: repo, file: repo.relativize(packageObj.selectedPath)
  else
    notifier.addInfo "No file selected to diff"
