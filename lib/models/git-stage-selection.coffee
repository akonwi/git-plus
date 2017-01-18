path = require 'path'
os = require 'os'
fs = require 'fs-plus'
git = require '../git'
notifier = require '../notifier'

regexForOriginalRange = /(\-\d+,\d+)/g
regexForChangeRange = /(\+\d+,\d+)/g
regexForLineCountInChangeRange = /(,\d+)/ # replace with ",[new count]"

getSelectedRange = ->
  range = atom.workspace.getActiveTextEditor().getSelectedBufferRange()
  range.end.row - range.start.row

generateObjects = (data) ->
  for hunk in data when hunk isnt ''
    hunkSplit = hunk.match /(@@[ \-\+\,0-9]*@@.*)\n([\s\S]*)/
    {
      pos: hunkSplit[1]
      patch: hunk
    }

stageSelection = (repo, selection, selectedCount) ->
  git.diff(repo, atom.workspace.getActiveTextEditor().getPath())
  .then (data) ->
    console.log data
    patchHeader = data[0]
    generateObjects(data[1..]).forEach (hunk) ->
      if hunk.patch.includes selection
        hunkLines = hunk.patch.split('\n')
        firstChangedLineIndex = hunkLines.findIndex (line) -> line.startsWith '+'
        toKeep = [patchHeader].concat(hunkLines.splice(0, firstChangedLineIndex))
        toKeep[0] = toKeep[0].trim()

        originalRange = toKeep[1].match(regexForOriginalRange)[0]
        newLineCount = selectedCount + parseInt(originalRange.match(/\d+/g)[1])
        newRange = toKeep[1].match(regexForChangeRange)[0].replace(regexForLineCountInChangeRange, ",#{newLineCount}")

        toKeep[1] = toKeep[1].replace(regexForChangeRange, newRange)
        change = hunkLines.filter (line) -> line.startsWith('+') and line.trim().includes(selection)
        toKeep = toKeep.concat(change)
        hunkLines.slice().reverse().forEach (line) ->
          toKeep.push(line) unless line.startsWith('+')
        patch = toKeep.filter((line) -> line isnt '').join('\n')
        patch += os.EOL
        console.log patch
        patchPath = path.join(repo.getPath(), 'GITPLUS_PATCH')
        fs.writeFile patchPath, patch, (err) ->
          unless err
            git.cmd(['apply', '--cached', '--recount', '--', patchPath], cwd: repo.getWorkingDirectory())
            .then (data) ->
              notifier.addSuccess('Hunk has been staged!')
              try fs.unlink patchPath
            .catch console.log
          else
            notifier.addError err

module.exports = (repo) ->
  selection = atom.workspace.getActiveTextEditor().getSelectedText().trim()
  selectedCount = getSelectedRange()
  stageSelection(repo, selection, selectedCount)
