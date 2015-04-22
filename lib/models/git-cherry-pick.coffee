git = require '../git'
CherryPickSelectBranch = require '../views/cherry-pick-select-branch-view'

gitCherryPick = (repo) ->
  heads = repo.getReferences().heads
  currentHead = repo.getShortHead()

  for head, i in heads
    heads[i] = head.replace('refs/heads/', '')

  heads = heads.filter (head) -> head isnt currentHead
  new CherryPickSelectBranch(repo, heads, currentHead)

module.exports = gitCherryPick
