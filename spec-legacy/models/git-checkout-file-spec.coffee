git = require '../../lib/git'
notifier = require '../../lib/notifier'
GitCheckoutFile = require '../../lib/models/git-checkout-file'
{repo} = require '../fixtures'

file = 'path/to/file'

describe "GitCheckoutFile", ->
  it "calls git.cmd with ['checkout', '--', filepath]", ->
    spyOn(git, 'cmd').andReturn Promise.resolve()
    GitCheckoutFile(repo, {file})
    expect(git.cmd).toHaveBeenCalledWith ['checkout', '--', file], cwd: repo.getWorkingDirectory()

  it "notifies the user when it fails", ->
    err = "error message"
    spyOn(git, 'cmd').andReturn Promise.reject(err)
    spyOn(notifier, 'addError')
    waitsForPromise -> GitCheckoutFile(repo, {file})
    runs -> expect(notifier.addError).toHaveBeenCalledWith err
