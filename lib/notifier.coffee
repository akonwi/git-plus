notify = require('atom-notify')('Git-Plus')
{addSuccess, addInfo, addError, addWarning} = notify

notify.addSuccess = ->
  note = addSuccess.call notify, arguments..., dismissable: true
  setTimeout((=> note.dismiss()), 5000)

notify.addInfo = ->
  note = addInfo.call notify, arguments..., dismissable: true
  setTimeout((=> note.dismiss()), 5000)

notify.addError = ->
  note = addError.call notify, arguments..., dismissable: true

notify.addWarning = ->
  note = addWarning.call notify, arguments..., dismissable: true
  setTimeout((=> note.dismiss()), 5000)

module.exports = notify
