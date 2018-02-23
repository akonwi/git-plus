'use babel'
const git = require('../../lib/git')
const GitCheckoutBranch = require('../../lib/models/git-checkout-branch')

const {repo} = require('../fixtures')
const cwd = repo.getWorkingDirectory()

describe("GitCheckoutBranch", () => {
  beforeEach(() => {
    spyOn(atom.workspace, 'addModalPanel').andCallThrough()
    spyOn(git, 'cmd').andReturn(Promise.resolve('branch1\nbranch2'))
  })

  describe("when the remote option is false", () => {
    it("gets a list of the repo's branches", () => {
      waitsForPromise(() => GitCheckoutBranch(repo))
      runs(() => {
        expect(git.cmd).toHaveBeenCalledWith(['branch', '--no-color'], {cwd})
        expect(atom.workspace.addModalPanel).toHaveBeenCalled()
      })
    })
  })

  describe("when the remote option is true", () => {
    it("gets a list of the repo's remote branches", () => {
      waitsForPromise(() => GitCheckoutBranch(repo, {remote: true}))
      runs(() => {
        expect(git.cmd).toHaveBeenCalledWith(['branch', '-r', '--no-color'], {cwd})
        expect(atom.workspace.addModalPanel).toHaveBeenCalled()
      })
    })
  })

  it("checkouts the selected branch", () => {
    waitsForPromise(() => GitCheckoutBranch(repo, {remote: true}).then(view => view.confirmSelection()))
    runs(() => {
      expect(git.cmd).toHaveBeenCalledWith(['checkout', 'branch1', '--track'], {cwd})
    })
  })
})
