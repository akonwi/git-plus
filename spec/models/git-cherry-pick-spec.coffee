{repo} = require '../fixtures'
GitCherryPick = require '../../lib/models/git-cherry-pick'

describe "GitCherryPick", ->
  it "gets heads from the repo's references", ->
    spyOn(repo, 'getReferences').andCallThrough()
    GitCherryPick repo
    expect(repo.getReferences).toHaveBeenCalled()

  it "calls replace on each head with to remove 'refs/heads/'", ->
    head = repo.getReferences().heads[0]
    GitCherryPick repo
    expect(head.replace).toHaveBeenCalledWith 'refs/heads/', ''
