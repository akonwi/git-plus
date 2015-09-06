{repo, pathToRepoFile} = require '../fixtures'
git = require '../../lib/git'
GitRun = require '../../lib/models/git-run'

## Can't trigger the the 'core:confirm' command
# describe "GitRun", ->
  # it "calls git.cmd with the arguments typed into the input", ->
  #   spyOn(git, 'cmd').andReturn Promise.resolve true
  #   view = GitRun(repo)
  #   view.commandEditor.setText 'do some stuff'
  #   atom.commands.dispatch(view, 'core:confirm')
  #   expect(git.cmd).toHaveBeenCalledWith ['do', 'some', 'stuff'], cwd: repo.getWorkingDirectory()
  #
  # it "calls git.add without a file option if `addAll` is true", ->
  #   spyOn(git, 'add')
  #   GitAdd(repo, addAll: true)
  #   expect(git.add).toHaveBeenCalledWith repo
