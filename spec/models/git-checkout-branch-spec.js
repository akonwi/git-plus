'use babel'
const git = require('../../lib/git')
const GitCheckoutBranch = require('../../lib/models/git-checkout-branch')

const {repo} = require('../fixtures')
const cwd = repo.getWorkingDirectory()

describe("GitCheckoutBranch", () => {
  let branchViewPromise

  beforeEach(() => {
    spyOn(atom.workspace, 'addModalPanel').andCallThrough()
    spyOn(git, 'cmd').andReturn(Promise.resolve('branch1\nbranch2'))
    waitsForPromise(() => branchViewPromise = GitCheckoutBranch(repo))
  })

  it("displays a list of the repo's branches", () => {
    expect(git.cmd).toHaveBeenCalledWith(['branch', '--no-color'], {cwd})
    expect(atom.workspace.addModalPanel).toHaveBeenCalled()
  })

  it("checkouts the selected branch", () => {
    waitsForPromise(() => branchViewPromise.then(view => view.confirmSelection()))
    runs(() => expect(git.cmd).toHaveBeenCalledWith ['checkout', 'branch1'], {cwd})
  })
})
