git = require '../../lib/git'
{repo} = require '../fixtures'
GitPull = require '../../lib/models/git-pull'
_pull = require '../../lib/models/_pull'

options =
  cwd: repo.getWorkingDirectory()

describe "Git Pull", ->
  beforeEach -> spyOn(git, 'cmd').andReturn Promise.resolve true

  describe "when 'promptForBranch' is disabled", ->
    it "calls git.cmd with ['pull'] and the upstream branch path", ->
      GitPull(repo)
      expect(git.cmd).toHaveBeenCalledWith ['pull', 'origin', 'foo'], options, {color: true}

  describe "when 'promptForBranch' is enabled", ->
    it "calls git.cmd with ['remote']", ->
      atom.config.set('git-plus.remoteInteractions.promptForBranch', true)
      GitPull(repo)
      expect(git.cmd).toHaveBeenCalledWith ['remote'], options

  describe "The pull function", ->
    it "calls git.cmd", ->
      _pull repo
      expect(git.cmd).toHaveBeenCalledWith ['pull', 'origin', 'foo'], options, {color: true}

    it "calls git.cmd with extra arguments if passed", ->
      _pull repo, extraArgs: ['--rebase']
      expect(git.cmd).toHaveBeenCalledWith ['pull', '--rebase', 'origin', 'foo'], options, {color: true}
