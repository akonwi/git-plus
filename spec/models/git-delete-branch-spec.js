'use babel'
const git = require('../../lib/git')
const GitDeleteBranch = require('../../lib/models/git-delete-branch')

const {repo} = require('../fixtures')
const cwd = repo.getWorkingDirectory()

describe("GitDeleteBranch", () => {
  describe("when the remote option is false", () => {
    beforeEach(() => {
      spyOn(git, 'cmd').andReturn(Promise.resolve('branch1\nbranch2'))
    })

    it("gets a list of the repo's branches", () => {
      waitsForPromise(() => GitDeleteBranch(repo))
      runs(() => {
        expect(git.cmd).toHaveBeenCalledWith(['branch', '--no-color'], {cwd})
      })
    })

    it("deletes the selected local branch", () => {
      waitsForPromise(() => GitDeleteBranch(repo).then(view => view.confirmSelection()))
      runs(() => expect(git.cmd).toHaveBeenCalledWith(['branch', '-D', 'branch1'], {cwd}))
    })
  })

  describe("when the remote option is true", () => {
    beforeEach(() => {
      spyOn(git, 'cmd').andReturn(Promise.resolve('origin/branch1\norigin/branch2'))
    })

    it("gets a list of the repo's remote branches", () => {
      waitsForPromise(() => GitDeleteBranch(repo, {remote: true}))
      runs(() => {
        expect(git.cmd).toHaveBeenCalledWith(['branch', '-r', '--no-color'], {cwd})
      })
    })

    it("deletes the selected remote branch", () => {
      waitsForPromise(() => GitDeleteBranch(repo, {remote: true}).then(view => view.confirmSelection()))
      runs(() => expect(git.cmd).toHaveBeenCalledWith(['push', 'origin', '--delete', 'branch1'], {cwd}))
    })
  })

})
