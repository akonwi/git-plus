git = require '../lib/git'
GitRun = require '../lib/models/git-run'
{repo} = require './fixtures'

describe "Git-Plus service", ->
  service = null

  beforeEach ->
    atom.config.set('git-plus.experimental.customCommands', true)
    service = require '../lib/service'

  describe "registerCommand", ->
    it "registers the given command with atom and saves it for the Git-Plus command palette", ->
      fn = () ->
      service.registerCommand('some-element', 'foobar:do-cool-stuff', fn)
      command = service.getCustomCommands()[0]
      expect(command[0]).toBe 'foobar:do-cool-stuff'
      expect(command[1]).toBe 'Do Cool Stuff'
      expect(command[2]).toBe fn

  describe "::getRepo", ->
    it "is the getRepo function", ->
      expect(git.getRepo).toBe service.getRepo

  describe "::run", ->
    it "is the GitRun function", ->
      expect(GitRun).toBe service.run
