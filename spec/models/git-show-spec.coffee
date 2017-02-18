Path = require 'path'
fs = require 'fs-plus'
Os = require 'os'
git = require '../../lib/git'
{repo, pathToRepoFile} = require '../fixtures'
GitShow = require '../../lib/models/git-show'

describe "GitShow", ->
  beforeEach ->
    spyOn(git, 'cmd').andReturn Promise.resolve 'foobar'

  it "calls git.cmd with 'show' and #{pathToRepoFile}", ->
    GitShow repo, 'foobar-hash', pathToRepoFile
    args = git.cmd.mostRecentCall.args[0]
    expect('show' in args).toBe true
    expect(pathToRepoFile in args).toBe true

  it "uses the format option from package settings", ->
    atom.config.set('git-plus.general.showFormat', 'fuller')
    GitShow repo, 'foobar-hash', pathToRepoFile
    args = git.cmd.mostRecentCall.args[0]
    expect('--format=fuller' in args).toBe true

  it "writes the output to a file", ->
    spyOn(fs, 'writeFile').andCallFake ->
      fs.writeFile.mostRecentCall.args[3]()
    outputFile = Path.join Os.tmpDir(), "foobar-hash.diff"
    waitsForPromise ->
      GitShow repo, 'foobar-hash', pathToRepoFile
    runs ->
      args = fs.writeFile.mostRecentCall.args
      expect(args[0]).toBe outputFile
      expect(args[1]).toBe 'foobar'

  describe "When a hash is not specified", ->
    it "returns a view for entering a hash", ->
      view = GitShow repo
      expect(view).toBeDefined()
