module.exports = (repo) ->
  repo = repo.getWorkingDirectory()
  atom.workspace.open "#{repo}/.git/info/excludes"
