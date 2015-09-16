git = require '../git'
notifier = require '../notifier'

gitDifftool = (repo, {file}={}) ->
  file ?= repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  if not file
    return notifier.addError "No open file. Select 'Diff All'."
  # We parse the output of git diff-index to handle the case of a staged file
  # when git-plus.includeStagedDiff is set to false.
  git.cmd
    args: ['diff-index', 'HEAD', '-z']
    cwd: repo.getWorkingDirectory()
    stdout: (data) ->
      diffIndex = data.split('\0')
      includeStagedDiff = atom.config.get 'git-plus.includeStagedDiff'
      for line, i in diffIndex by 2
        staged = not /^0{40}$/.test(diffIndex[i].split(' ')[3]);
        path = diffIndex[i+1]
        if path is file and (!staged or includeStagedDiff)
          args = ['difftool']
          args.push 'HEAD' if includeStagedDiff
          args.push file
          git.cmd
            args: args
            cwd: repo.getWorkingDirectory()
          return
      # If file is unchanged, or staged, but git-plus.includeStagedDiff unchecked
      notifier.addInfo 'Nothing to show.'

module.exports = gitDifftool
