git = require '../git'
CherryPickSelectBranch = require '../views/cherry-pick-select-branch-view'

gitCherryPick = ->
  repo = git.getRepo()
  heads = repo.getReferences().heads
  currentHead = repo.getShortHead()

  for head, i in heads
    heads[i] = head.replace('refs/heads/', '')

  heads = heads.filter (head) -> head isnt currentHead
  new CherryPickSelectBranch(heads, currentHead)

module.exports = gitCherryPick
