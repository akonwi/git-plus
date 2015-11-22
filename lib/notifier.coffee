notify = require('atom-notify')('Git-Plus')
{addSuccess, addInfo, addError, addWarning} = notify

notify.addSuccess = ->
  addSuccess.call notify, arguments..., dismissable: true

notify.addInfo = ->
  addInfo.call notify, arguments..., dismissable: true

notify.addError = ->
  addError.call notify, arguments..., dismissable: true

notify.addWarning = ->
  addWarning.call notify, arguments..., dismissable: true

module.exports = notify
