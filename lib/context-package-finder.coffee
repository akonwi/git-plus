module.exports =
  get: ->
    if atom.packages.isPackageLoaded('tree-view')
      treeView = atom.packages.getLoadedPackage('tree-view')
      treeView = require(treeView.mainModulePath).getTreeViewInstance()
      treeView.serialize()
