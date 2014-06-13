fs = require 'fs-plus'
git = require '../git'
StatusView = require '../views/status-view'

amend = null
currentPane = atom.workspace.getActivePane()
file = '.git/COMMIT_EDITMSG'
dir = atom.project.getRepo()?.getWorkingDirectory() ? atom.project.getPath()

gitCommit = (_amend='') ->
  if amend?
    atom.workspace.open(file, activatePane: true, searchAllPanes: true)
    return

  amend = _amend
  git.cmd(
    args: ['status'],
    stdout: (data) -> prepFile data, amend
  )

# FIXME?: maybe I shouldn't use the COMMIT file in .git/
prepFile = (status, amend) ->
  # format the status to be ignored in the commit message
  status = status.replace(/\s*\(.*\)\n/g, '')
  status = status.trim().replace(/\n/g, "\n# ")
  fs.writeFileSync "#{dir}/#{file}",
     """#{amend}
      # Please enter the commit message for your changes. Lines starting
      # with '#' will be ignored, and an empty message aborts the commit.
      # Remove hyphen(-) and update commit message as necessary for amend.
      #
      # #{status}"""
  showFile()

showFile = ->
  split = if atom.config.get('git-plus.openInPane') then 'right' else ''
  atom.workspace
    .open(file, split: split, activatePane: true, searchAllPanes: true)
    .done (editor) ->
      editor.buffer.on 'saved', -> commit()
      editor.buffer.on 'destroyed', -> cleanup()

commit = ->
  args = ['commit', '--cleanup=strip', "--file=#{file}"]
  args.push '--amend' if amend isnt ''
  git.cmd(
    args: args,
    stdout: (data) ->
      new StatusView(type: 'success', message: data.toString())
      if atom.workspace.getActivePane().getItems().length > 1
        atom.workspace.destroyActivePaneItem()
      else
        atom.workspace.destroyActivePane()
      atom.project.getRepo()?.refreshStatus()
  )

cleanup = ->
  amend = null
  currentPane.activate()
  try fs.unlinkSync "#{dir}/#{file}"
  
module.exports = gitCommit
