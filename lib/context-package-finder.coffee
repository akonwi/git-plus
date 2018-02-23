module.exports =
  get: ->
    if atom.packages.isPackageLoaded('tree-view')
      treeView = atom.packages.getLoadedPackage('tree-view')
      treeView = require(treeView.mainModulePath).getTreeViewInstance()
      treeView.serialize()
    else if atom.packages.isPackageLoaded('sublime-tabs')
      sublimeTabs = atom.packages.getLoadedPackage('sublime-tabs')
      sublimeTabs = require(sublimeTabs.mainModulePath)
      sublimeTabs.serialize()
