git = require '../../lib/git'
GitFetchAll = require '../../lib/models/git-fetch-all'
{repo} = require '../fixtures'

describe "GitFetchAll", ->
  beforeEach ->
    spyOn(git, 'cmd').andReturn Promise.resolve()

  it "runs `git fetch --all` for each repo passed to it", ->
    repo2 = Object.create(repo)
    repo2.getWorkingDirectory = -> 'repo2'
    repos = [repo, repo2]
    GitFetchAll(repos)
    repos.forEach (r) ->
      expect(git.cmd).toHaveBeenCalledWith ['fetch', '--all'], cwd: r.getWorkingDirectory()

  it 'shows a notification if the configuration to show notifications is true', ->
    spyOn(atom.config, 'get').andReturn true
    addSuccess = spyOn(atom.notifications, 'addSuccess')
    GitFetchAll([repo])[0].then ->
      expect(addSuccess).toHaveBeenCalled()
