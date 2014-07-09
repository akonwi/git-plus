git = require '../git'
CherryPickSelectBranch = require '../views/cherry-pick-select-branch-view'

gitCherryPick = ->
  atomGit = atom.project.getRepo(atom.workspace.getActiveEditor()?.getPath())
  heads = atomGit.getReferences().heads
  currentHead = atomGit.getShortHead()

  for head, i in heads
    heads[i] = head.replace('refs/heads/', '')

  heads = heads.filter (head) -> head isnt currentHead
  new CherryPickSelectBranch(heads, currentHead)

module.exports = gitCherryPick
