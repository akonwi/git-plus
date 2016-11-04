{repo, pathToRepoFile} = require '../fixtures'
git = require '../../lib/git'
GitRun = require '../../lib/models/git-run'

describe "GitRun", ->
  it "calls git.cmd with the arguments typed into the input with a config for colors to be enabled", ->
    spyOn(git, 'cmd').andReturn Promise.resolve true
    view = GitRun(repo)
    editor = view.find('atom-text-editor')[0]
    view.commandEditor.setText 'do some stuff'
    atom.commands.dispatch(editor, 'core:confirm')
    expect(git.cmd).toHaveBeenCalledWith ['do', 'some', 'stuff'], cwd: repo.getWorkingDirectory(), {color: true}
